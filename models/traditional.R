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
apply_budget <- function(necessary_actions,
                         current_budget,
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

  # If skip_large is TRUE, a for loop is required
  # This may result in worse peformance on large datasets
  if (skip_large) {
    necessary_actions %>% 

      # Spend less than or equal to the budget for a given year
      # In the case that adding the current cost would cause the total_cost to be over the budget, skip
      # that record and return the total_cost for the previous record
      mutate(total_cost = accumulate(cost, ~ if (.x + .y <= current_budget) .x + .y else .x, .init = 0)[-1]) %>% 
      
      # Remove records who have the same total_cost as the previous record, since this means that 
      # adding that record would have exceeded the budget
      # The replace_na is used to not drop the first row since lag(total_cost) would be NA for that record
      # There should be no other NAs that are replaced here
      filter(total_cost != replace_na(lag(total_cost), 0))  

  }

  # If skip_large is FALSE, use cumsum for better optimization
  else {
    necessary_actions %>% 

      # Spend less than or equal to the budget for a given year
      mutate(total_cost = cumsum(cost)) %>% 
      filter(total_cost <= current_budget)  

  }          
}


# ---- traditional_run ----
traditional_run <- function(assets,
                            asset_types,
                            asset_actions,
                            budget,
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
  test_budget(budget, start_year, end_year)

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

    # Get budget for current_year
    current_budget <- budget %>%
      filter(year == current_year) %>% 
      pull(budget)
    
    # Get a list of replacements that need to be made in year
    actions[[current_year]] <- asset_details %>% 
    
      necessary_actions_wrapper(necessary_actions, ., previous_actions, current_year) %>% 
      
      # Apply cost adjustments
      cost_adjustment_wrapper(cost_adjustment, ., current_year, start_year) %>% 
      
      # Order based on priorities
      priorities_wrapper(priorities, ., current_year) %>% 
      
      # Apply budget
      apply_budget(current_budget, skip_large) %>% 

      # Add the year of the replacement as a column
      mutate(year = current_year) %>% 
      
      subset(select = c(year, asset_id, asset_type_id, asset_action_id, cost))
    
    # Carry over left over budget if carryover is TRUE
    if (carryover) {

      # Calculate the amount of left over budget
      left_over_budget <- current_budget - actions[[current_year]] %>% 
        summarize(total_cost = sum(cost, na.rm = TRUE)) %>% 
        pull(total_cost)

      # Update the budget for the next year with the leftovers
      budget <- budget %>% 
        mutate(budget = if_else(year == current_year + 1, budget + left_over_budget, budget))
    }

    # Perform annual adjustments
    assets <- annual_adjustment_wrapper(annual_adjustment,
                                        assets, 
                                        asset_types, 
                                        asset_actions, 
                                        actions[[current_year]], 
                                        current_year)

  }

  # Combine all years worth of replacements into a single dataframe
  do.call(rbind, actions)
}