# This file contains the backlog_seek model


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
  necessary_actions = actions_by_age,
  proportion = FALSE
) {
  "
  See functions/models.md           
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
  test_backlog_sought(backlog_sought, proportion, start_year, end_year)

  # For each year between start_year and end_year (excluding start_year), note every asset
  # that needs to be replaced and update its value in asset_details
  actions <- list()
  backlog <- list()
  for (current_year in start_year:end_year){

    # Left join asset_types and asset_actions on to assets
    asset_details <- assets %>% 
      left_join(asset_types, by = "asset_type_id") %>% 
      left_join(asset_actions, by = "asset_type_id", relationship = "many-to-many")

    # Get the subset of assets that need to be replaced in year
    previous_actions <- do.call(bind_rows, actions)
    
    # Get a list of asset-action combinations that need to be made in year
    prioritized_necessary_actions <- asset_details %>% 
    
      necessary_actions_wrapper(necessary_actions, ., previous_actions, current_year) %>% 
      
      # Apply cost adjustments
      cost_adjustment_wrapper(cost_adjustment, ., current_year, start_year) %>% 
      
      # Order based on action_priorities
      action_priorities_wrapper(action_priorities, ., current_year) %>% 
      
      # Get the total cost of the backlog if the current record is the 
      # first unfunded action
      mutate(backlog_cost = rev(cumsum(rev(cost))), default = 0)
    
    # Perform actions up to the point where the backlog for the year is below the value 
    # specified in the backlog table
    # Do not perform any actions in the first year to establish a baseline
    if (current_year == start_year) {
      performed_actions <- tibble()
    } else {
      performed_actions <- prioritized_necessary_actions %>% 
        filter(backlog_cost > backlog_sought %>%
            filter(year == current_year) %>% 
            pull(backlog)
          ) %>% 
        subset(select = -backlog_cost)
    }

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

      # If proportion is true, reset the backlog_sought values to be proportions
      # of the backlog in start_year
      if (proportion & current_year == start_year) {
        start_year_backlog <- backlog[[current_year]] %>% 
          summarize(cost = sum(cost)) %>% 
          pull()
        # This is not done using tidyverse because it was getting funky with both the field
        # and the separate list being named backlog
        backlog_sought$backlog <- backlog_sought$backlog * start_year_backlog
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
