# This file contains the backlog_seek model

library(tidyverse)
library(here)

source(here("functions/preflight.R"))
source(here("functions/action_priorities.R"))
source(here("functions/annual_adjustment.R"))
source(here("functions/cost_adjustment.R"))
source(here("functions/necessary_actions.R"))


backlog_seek <- function(
  assets,
  asset_types,
  asset_actions,
  backlog_sought,
  start_year,
  end_year,
  action_priorities = prioritize_longest_wait,
  annual_adjustment = replace_assets,
  cost_adjustment = inflation,
  necessary_actions = actions_by_age
) {
  "
  Parameters:
    assets - See docs/input_tables.md
    asset_types - See docs/input_tables.md
    asset_actions - See docs/input_tables.md
    backlog_sought - See docs/input_table.md
    start_year - The first year the model calculates actions for. This should be an
      integer value. This should be <= end_year.
    end_year - That last year the model calculates actions for. This should be an
      integer value. This should >= start_year.
    action_priorities - See docs/functions.md
    annual_adjustment - See docs/functions.md
    cost_adjustment - See docs/dunctions.md
    necessary_actions - See docs/functions.md

  Returns:
    performed_actions - see output_tables.md 
    backlog - see output_tables.md
  This run aims to return the necessary spending to get a certain cost value in the backlog 
    for each year               
  "

  # Assert that start_year and end_year and integers and start_year <= end_year
  year_order(start_year, end_year)

  # Assert that the asset_types tibble meets its requirements
  test_asset_types(asset_types)

  # Assert that the assets tibble meets its requirements
  test_assets(assets, asset_types, start_year)

  # Assert that the asset_actions tibble meets its requirements
  test_asset_actions(asset_actions, asset_types)

  # Assert that the backlog_sought tibble meets its requirements
  test_backlog_sought(backlog_sought, start_year, end_year)

  # For each year between start_year and end_year (including both), note every asset
  # that needs to be replaced and update its value in asset_details
  actions <- list()
  backlog <- list()
  for (current_year in start_year:end_year){

    # Left join asset_types and asset_actions on to assets
    asset_details <- assets %>% 
      left_join(asset_types, by = "asset_type_id") %>% 
      left_join(asset_actions, by = "asset_type_id", relationship = "many-to-many")

    # Get the subset of assets that need to be replaced in year
    previous_actions <- do.call(rbind, actions)
    
    # Get a list of asset-action combinations that need to be made in year
    prioritized_necessary_actions <- asset_details %>% 
    
      necessary_actions_wrapper(necessary_actions, ., previous_actions, current_year) %>% 
      
      # Apply cost adjustments
      cost_adjustment_wrapper(cost_adjustment, ., current_year, start_year) %>% 
      
      # Order based on action_priorities
      action_priorities_wrapper(action_priorities, ., current_year) %>% 
      
      # Get the total cost of the backlog if the current record is the last action that
      # is funded
      mutate(backlog_cost = lag(rev(cumsum(rev(cost))), default = 0))
    
    # Perform actions up to the point where the backlog for the year is below the value 
    # specified in the backlog table
    performed_actions <- prioritized_necessary_actions %>% 
      filter(backlog_cost >= backlog_sought %>%
          filter(year == current_year) %>% 
          pull(backlog)
        ) %>% 
      subset(select = -backlog_cost)

    # Skip the following if there are no necessary actions
    if (length(prioritized_necessary_actions) > 0) {

      # Skip the following steps if there are no performed_actions
      if (length(performed_actions) > 0) {

        # Set performed actions for the current_year
        actions[[current_year]] <- performed_actions %>% 

          # Add the year of the replacement as a column
          mutate(year = current_year) %>% 
          
          subset(select = c(year, asset_id, asset_type_id, action_id, cost))
        
        # Get backlog for the current year as all necessary actions that were not performed
        backlog[[current_year]] <- prioritized_necessary_actions %>% 

          # Get all actions that were not performed
          anti_join(performed_actions, join_by(asset_id == asset_id, action_id == action_id)) %>% 
          
          mutate(year = current_year) %>% 
          subset(select = c(year, asset_id, asset_type_id, action_id, cost))

        # Perform annual adjustments
        assets <- annual_adjustment_wrapper(
          annual_adjustment,
          assets, 
          asset_types, 
          asset_actions, 
          actions[[current_year]], 
          current_year
        )
        
      # Get the backlog in the case where no actions were performed, but some were necessary
      } else {
        backlog[[current_year]] <- prioritized_necessary_actions %>%           
          mutate(year = current_year) %>% 
          subset(select = c(year, asset_id, asset_type_id, action_id, cost))
      }
      
    }

  }

  # Create a single object with all the results
  result <- list(
    performed_actions = do.call(bind_rows, actions),
    backlog = do.call(bind_rows, backlog)
  )

  class(result) <- "backlog_seek_tammi_model"

  return(result)
}
