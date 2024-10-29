# This file contains the traditional_run function
# This file is tested by tests/traditional_test.R

library(tidyverse)
library(here)

source(here("functions/preflight.R"))
source(here("functions/necessary_actions.R"))
source(here("functions/cost_adjustment.R"))


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
  necessary_actions

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
                            necessary_actions = replace_by_age,
                            cost_adjustment = inflation,
                            skip_large = TRUE) {
  "
  Parameters:
    assets - see input_tables.md
    asset_types - see input_tables.md
    asset_actions - see input_tables.md
    budget - see input_table.md
    start_year - The first year the model calculates actions for. This should be an
      integer value. This should be <= end_year.
    end_year - That last year the model calculates actions for. This should be an
      integer value. This should >= start_year.
    necessary_actions - A function that meets the parameters laid out in
      functions/necessary_actions.R. replace_by_age by default.
    cost_adjustment - A function that meets the requirements laid out in
      functions/cost_adjustment.R inflation with an inflation_rate of 0.03 by default.
    skip_large - A boolean value. If skip_large is true, then in the case where skipping an
      expensive action in the prioritized list of necessary actions reveals a cheaper action
      that is still within budget, the algorithm will choose this approach. This should
      not be used when carryover is also TRUE. Note that setting skip_large to TRUE may
      be less efficient only larger datasets.

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

  # For each year between start_year and end_year (including both), note every asset
  # that needs to be replaced and update its value in asset_details
  actions <- list()
  for (current_year in start_year:end_year){

    # Left join asset_types and asset_actions on to assets
    asset_details <- assets %>% 
      merge(asset_types, by = "asset_type_id") %>% 
      merge(asset_actions, by = "asset_type_id")

    # Get the subset of assets that need to be replaced in year
    previous_actions <- do.call(rbind, actions)

    # Get budget for current_year
    current_budget <- budget %>%
      filter(year == current_year) %>% 
      pull(budget)
    
    # Get a list of replacements that need to be made in year
    actions[[current_year]] <- asset_details %>% 
    
      necessary_actions(previous_actions, current_year) %>% 
      
      # Apply cost adjustments
      cost_adjustment(current_year, start_year) %>% 
      
      # Apply budget
      apply_budget(current_budget, skip_large) %>% 

      # Add the year of the replacement as a column
      mutate(year = current_year) %>% 
      
      subset(select = c(year, asset_id, asset_type_id, asset_action_id, cost))

    # Get the subset of actions for the current year that are replacements
    replacements <- actions[[current_year]] %>% 
      left_join(asset_actions, by = "asset_action_id") %>% 
      filter(replacement_flag == 1)

    # Update year_built for assets that have been replaced
    assets <- assets %>% 
      mutate(year_built = ifelse(asset_id %in% replacements$asset_id,
                                 current_year,
                                 year_built))
  }

  # Combine all years worth of replacements into a single dataframe
  do.call(rbind, actions)
}