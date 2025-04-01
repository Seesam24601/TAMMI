# This file contains the traditional_run function
# This file is tested by tests/traditional_test.R

library(tidyverse)
library(here)

source(here("functions/preflight.R"))
source(here("functions/action_priorities.R"))
source(here("functions/annual_adjustment.R"))
source(here("functions/budget_carryover.R"))
source(here("functions/budget_priorities.R"))
source(here("functions/cost_adjustment.R"))
source(here("functions/necessary_actions.R"))


# ---- apply_budget -----
apply_budget <- function(
  prioritized_necessary_actions,
  budgets,
  budget_years,
  budget_actions,
  current_year,
  budget_priorities,
  skip_large
) {
  "
  Parameters:
    necessary_actions - Result of joining assets, asset_types, and asset_actions (also known
      as asset_details) that has been subsetted to the necessary actions, had cost adjustments
      applied, and prioritized
    budgets - See docs/input_tables.md
    budget_years - See docs/input_tables.md
    budget_actions - See docs/input_tables.md
    current_year - Integer value for the year being modeled                      
    budget_priorities - See docs/functions.md
    skip_large - See traditional_run documentation at the top of the traditional_run file

  Returns:
    The subset of necessary_actions that can be paid for given the current budget as constrained
  by the additional settings like skip_large and carryover
  "

  # Create a column to track whether or not a budget has a necessary action that there is not
  # enough budget to perform this year
  # This is used when skip_large is set to FALSE
  budget_years <- budget_years %>% 
    mutate(skip_flag = FALSE)

  # Create an empty vector add performed actions to
  # After every necessary action has been considered, this vector will be row binded into a single tibble
  performed_actions <- list()

  # Loop through every necessary action
  for (i in 1:nrow(prioritized_necessary_actions)){

    # Get a tibble that represents the necessary action and the budgets that could be used to pay for it
    possbile_budgets <- prioritized_necessary_actions %>% 

      # Only look at the asset-action combination in row i of the necessary_actions table
      filter(row_number() == i) %>% 

      # Get all available budgets for a given action
      # I considered performing this line outside the loop, as it should be more performant,
      # but doing so makes iterating over the asset-action combinations more complicated
      # In the future, changing this may be worth it if performance is a problem
      inner_join(budget_actions, by = join_by(action_id)) %>% 
      
      # Get the current value in each budget
      inner_join(

        # Only look at the current year of budgets
        budget_years %>% 
          filter(year == current_year), 

        by = join_by(budget_id)
      ) %>% 
      
      # Left join budgets table in case there is information at the budget level that someone wans to filter
      # by in budget_priorities
      left_join(budgets, by = join_by(budget_id))
    
    # Get a signle row that represents the necessary action and the budget that WILL be used to pay for it
    performed_action <- possbile_budgets %>% 
      
      filter(
        
        # Only consider budgets that have another budget remaining to cover the cost of the action
        cost <= budget,
      
        # Exclude budgets where skip_flag is TRUE (there has already been an action that budget
        # could have funded that was skipped) when skip_large is FALSE
        (skip_large | !skip_flag)

      ) %>% 
      
      budget_priorities_wrapper(budget_priorities, .)
    
      # It is not necessary to restrict the fields returned since that task is performed in the 
      # traditional_run function before the result is returns
      # Note that the budget value is not updated here, but instead by altering the budgets tibble
  
    # In the case that there is enough budget to perform the action
    if (nrow(performed_action) == 1){
      
      # Remove that cost from the current_year of the correct budget
      budget_years <- budget_years %>% 
        mutate(
          budget = if_else(
            budget_id == pull(performed_action, budget) & year == current_year,
            budget - pull(performed_action, cost),
            budget
          )
        )
      
      # Add action to list of performed actions
      performed_actions[[i]] <- performed_action

    }

    # Otherwise, update skip_flag for each budget applicable to this action to be TRUE
    else {

      budget_years <- budget_years %>% 
        mutate(
          skip_flag = if_else(
            budget_id %in% possbile_budgets$budget_id,
            TRUE,
            skip_flag
          )
        )
    }

  }   

  # Remove skip_flag column, as it is a temporary field only necessary to implement this function
  budget_years <- budget_years %>% 
    subset(select = -skip_flag)
  
  # Combine all performed_actions into a single tibble that is returned
  # Also return the budgets tibble as it has been updated with the current budget values
  list(
    performed_actions = do.call(bind_rows, performed_actions), 
    budget_years = budget_years
  )

}


# ---- traditional_run ----
traditional_run <- function(
  assets,
  asset_types,
  asset_actions,
  budgets,
  budget_years,
  budget_actions,
  start_year,
  end_year,
  action_priorities = prioritize_longest_wait,
  annual_adjustment = replace_assets,
  budget_carryover = carryover_all,
  budget_priorities = prioritize_first,
  cost_adjustment = inflation,
  necessary_actions = actions_by_age,
  skip_large = FALSE
) {
  "
  Parameters:
    assets - See docs/input_tables.md
    asset_types - See docs/input_tables.md
    asset_actions - See docs/input_tables.md
    budgets - See docs/input_table.md
    budget_years - See docs/input_table.md
    budget_Actions - See docs/input_table.md
    start_year - The first year the model calculates actions for. This should be an
      integer value. This should be <= end_year.
    end_year - That last year the model calculates actions for. This should be an
      integer value. This should >= start_year.
    action_priorities - See docs/functions.md
    annual_adjustment - See docs/functions.md
    budget_carryover - See docs/functions.md
    budget_priorities - See docs/functions.md
    cost_adjustment - See docs/dunctions.md
    necessary_actions - See docs/functions.md
    skip_large - A boolean value. If skip_large is true, then in the case where skipping an
      expensive action in the prioritized list of necessary actions reveals a cheaper action
      that is still within budget, the algorithm will choose this approach. This should
      not be used when carryover is also TRUE.

  Returns:
    performed_actions - see output_tables.md 
  This run is constrained in the amount of spending per year by budgets                      
  "
  
  # Assert that start_year and end_year and integers and start_year <= end_year
  year_order(start_year, end_year)

  # Assert that the asset_types tibble meets its requirements
  test_asset_types(asset_types)

  # Assert that the assets tibble meets its requirements
  test_assets(assets, asset_types, start_year)

  # Assert that asset_actions tibble meets its requirements
  test_asset_actions(asset_actions, asset_types)

  # Assert that budgets tibble meets its requirements
  test_budgets(budgets)

  # Assert that budget_years tibble meets its requirements
  test_budget_years(budget_years, budgets, start_year, end_year)

  # Assert that budget_sctions tibble meets its requirements
  test_budget_actions(budget_actions, budgets, asset_actions)

  # For each year between start_year and end_year (including both), note every asset
  # that needs to be replaced and update its value in asset_details
  actions <- list()
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
      action_priorities_wrapper(action_priorities, ., current_year)
    
    # Apply budgets and get both performed_actions and an updated budgets object from the results
    results <- prioritized_necessary_actions %>% 
      apply_budget(budgets, budget_years, budget_actions, current_year, budget_priorities, skip_large)
    performed_actions <- results$performed_actions
    budget_years <- results$budget_years

    # Skip the following steps if there are no performed_actions
    if (length(performed_actions) > 0) {

      # Set performed actions for the current_year
      actions[[current_year]] <- performed_actions %>% 

        # Add the year of the replacement as a column
        mutate(year = current_year) %>% 
        
        subset(select = c(year, asset_id, asset_type_id, action_id, budget_id, cost))

      # Perform annual adjustments
      assets <- annual_adjustment_wrapper(
        annual_adjustment,
        assets, 
        asset_types, 
        asset_actions, 
        actions[[current_year]], 
        current_year
      )
      
    }

    # Carryover leftover money from one year to the next in budgets where applicable

    # Do not carryover if the current_year is the end_year because this may cause errors
    # when trying to select certain rows from the budget_years_detailed table
    if (current_year != end_year) {
      budget_years <- budget_carryover_wrapper(
        budget_carryover,
        budgets,
        budget_years,
        current_year
      )
    }

  }

  # Combine all years worth of replacements into a single dataframe
  do.call(bind_rows, actions)
}