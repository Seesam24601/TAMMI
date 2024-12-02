# This file contains the traditional_run function
# This file is tested by tests/traditional_test.R

library(tidyverse)
library(here)

source(here("functions/preflight.R"))
source(here("functions/necessary_actions.R"))
source(here("functions/cost_adjustment.R"))
source(here("functions/priorities.R"))
source(here("functions/annual_adjustment.R"))


# ---- apply_budget -----
apply_budget <- function(prioritized_necessary_actions,
                         budgets,
                         budget_actions,
                         current_year,
                         skip_large) {
  "
  Parameters:
    necessary_actions - result of joining assets, asset_types, and asset_actions (also known
      as asset_details) that has been subsetted to the necessary actions, had cost adjustments
      applied, and prioritized
    current_budget - value of the budget for the current year; this should be integer-valued
    skip_large - see traditional_run documentation

  Returns:
    The subset of necessary_actions that can be paid for given the current budget as constrained
  by the additional settings like skip_large and carryover
  "

  # Create an empty vector add performed actions to
  # After every necessary action has been considered, this vector will be row binded into a single tibble
  performed_actions <- list()

  # print(prioritized_necessary_actions)

  # Loop through every necessary action
  for (i in 1:nrow(prioritized_necessary_actions)){

    # Get a single row that represents the necessary action and the budget that will be used to pay for it
    performed_action <- prioritized_necessary_actions %>% 

      # Only look at the asset-action combination in row i of the necessary_actions table
      filter(row_number() == i) %>% 

      # Get all available budgets for a given action
      # I considered performing this line outside the loop, as it should be more performant,
      # but doing so makes iterating over the asset-action combinations more complicated
      # In the future, changing this may be worth it if performance is a problem
      inner_join(budget_actions, by = join_by(action_id == action_id)) %>% 
      
      # Get the current value in each budget
      inner_join(

        # Only look at the current year of budgets
        budgets %>% 
          filter(year == current_year), 

        by = join_by(budget_id == budget_id)
      ) %>% 
      
      # Only consider budgets that have another budget remaining to cover the cost of the action
      filter(cost <= budget) %>% 
      
      # Get the top row
      # In the future, this should use a new user-suppliable function to prioritize which budget
      # to use. 
      # That function should require that the result is a tibble with either 0 or 1 rows
      slice(1)
    
      # It is not necessary to restrict the fields returned since that task is performed in the 
      # traditional_run function before the result is returns
      # Note that the budget value is not updated here, but instead by altering the budgets tibble
  
    # In the case that there is enough budget to perform the action
    if (nrow(performed_action) == 1){
      
      # Remove that cost from the current_year of the correct budget
      budgets <- budgets %>% 
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
  }   
  
  # Combine all performed_actions into a single tibble that is returned
  # Also return the budgets tibble as it has been updated with the current budget values
  list(
    performed_actions = do.call(bind_rows, performed_actions), 
    budgets = budgets
  )

}


# ---- traditional_run ----
traditional_run <- function(assets,
                            asset_types,
                            asset_actions,
                            budgets,
                            budget_actions,
                            start_year,
                            end_year,
                            necessary_actions = actions_by_age,
                            cost_adjustment = inflation,
                            priorities = prioritize_longest_wait,
                            annual_adjustment = replace_assets,
                            skip_large = FALSE,
                            carryover = TRUE) {
  "
  Parameters:
    assets - See docs/input_tables.md
    asset_types - See docs/input_tables.md
    asset_actions - See docs/input_tables.md
    budget - See docs/input_table.md
    start_year - The first year the model calculates actions for. This should be an
      integer value. This should be <= end_year.
    end_year - That last year the model calculates actions for. This should be an
      integer value. This should >= start_year.
    necessary_actions - See docs/functions.md
    cost_adjustment - See docs/functions.md
    priorities - See docs/functions.md
    annual_adjustments - See docs/functions.md
    skip_large - A boolean value. If skip_large is true, then in the case where skipping an
      expensive action in the prioritized list of necessary actions reveals a cheaper action
      that is still within budget, the algorithm will choose this approach. This should
      not be used when carryover is also TRUE. Note that setting skip_large to TRUE may
      be less efficient only larger datasets.
    carryover - A boolean value. If true, then unused money in the budget for after year X
      will be added to the budget for year X + 1. This should not be used when skip_large is TRUE

  Returns:
    performed_actions - see output_tables.md 
  This run is constrained in the amount of spending per year by budget                      
  "
  
  # Assert that start_year and end_year and integers and start_year <= end_year
  year_order(start_year, end_year)

  # Assert that the asset_types dataframe meets its requirements
  test_asset_types(asset_types)

  # Assert that the assets dataframe meets its requirements
  test_assets(assets, asset_types, start_year)

  # Assert that asset_actions dataframe meets its requirements
  test_asset_actions(asset_actions, asset_types)

  # Assert that budget dataframe meets its requirements
  # This will be updated to reflect the new budgets and budget_actions tables in the future
  # test_budget(budget, start_year, end_year)

  # Warn users if both skip_large and carryover are set to TRUE
  warning_message <- "Both skip_large and carryover are set to TRUE"
  if (skip_large & carryover) {
    warning(warning_message, call. = FALSE)
  }

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
      
      # Order based on priorities
      priorities_wrapper(priorities, ., current_year)
    
    # Apply budgets and get both performed_actions and an updated budgets object from the results
    results <- prioritized_necessary_actions %>% 
      apply_budget(budgets, budget_actions, current_year, skip_large)
    performed_actions <- results$performed_actions
    budgets <- results$budgets

    # Skip the following steps if there are no performed_actions
    if (length(performed_actions) > 0) {

      # Set performed actions for the current_year
      actions[[current_year]] <- performed_actions %>% 

        # Add the year of the replacement as a column
        mutate(year = current_year) %>% 
        
        subset(select = c(year, asset_id, asset_type_id, action_id, budget_id, cost))

      # Carry over left over budget if carryover is TRUE
      # This needs to be updated to use the new multiple budget system
      # That will be completed at a later date
      # if (carryover) {

      #   # Calculate the amount of left over budget
      #   left_over_budget <- current_budget - actions[[current_year]] %>% 
      #     summarize(total_cost = sum(cost, na.rm = TRUE)) %>% 
      #     pull(total_cost)

      #   # Update the budget for the next year with the leftovers
      #   budget <- budget %>% 
      #     mutate(budget = if_else(year == current_year + 1, budget + left_over_budget, budget))
      # }

      # Perform annual adjustments
      assets <- annual_adjustment_wrapper(annual_adjustment,
                                          assets, 
                                          asset_types, 
                                          asset_actions, 
                                          actions[[current_year]], 
                                          current_year)
      
    }
  }

  # print(actions)

  # Combine all years worth of replacements into a single dataframe
  do.call(bind_rows, actions)
}