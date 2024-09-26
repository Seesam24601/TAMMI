# This file contains the unconstrained_run functions
# This file is tested by tests/unconstrained_test.R

library(tidyverse)
library(here)

source(here("functions/preflight.R"))
source(here("functions/necessary_actions.R"))
source(here("functions/cost_adjustment.R"))


# ---- unconstrained ----
unconstrained <- function(assets,
                          asset_types,
                          asset_actions,
                          start_year,
                          end_year,
                          necessary_actions = replace_by_age,
                          cost_adjustment = inflation) {
  "
  Parameters:
    assets - see input_tables.md
    asset_types - see input_tables.md
    asset_actions - see input_tables.md
    start_year - The first year the model calculates actions for. This should be an
      integer value. This should be <= end_year.
    end_year - That last year the model calculates actions for. This should be an
      integer value. This should >= start_year.
    necessary_actions - A function that meets the parameters laid out in
      functions/necessary_actions.R. replace_by_age by default.
    cost_adjustment - A function that meets the requirements laid out in
      functions/cost_adjustment.R inflation with an inflation_rate of 0.03 by default.

  Returns:
    performed_actions - see output_tables.md                       
  "
  
  # Assert that start_year and end_year and integers and start_year <= end_year
  year_order(start_year, end_year)

  # Assert that the asset_types dataframe meets its requirements
  test_asset_types(asset_types)

  # Assert that the assets dataframe meets its requirements
  test_assets(assets, asset_types, start_year)

  # Left join asset_types and asset_actions on to assets
  asset_details <- assets %>% 
    merge(asset_types, by = "asset_type_id") %>% 
    merge(asset_actions, by = "asset_type_id")

  # For each year between start_year and end_year (including both), note every asset
  # that needs to be replaced and update its value in asset_details
  actions <- list()
  for (year in start_year:end_year){
    
    # Get a list of replacements that need to be made in year
    actions[[year]] <- asset_details %>% 

      # Get the subset of assets that need to be replaced in year
      necessary_actions(year) %>% 
      
      # Apply cost adjustments
      cost_adjustment(year, start_year) %>% 

      # Add the year of the replacement as a column
      mutate(year = year) %>% 
      
      subset(select = c(year, asset_id, asset_type_id, asset_action_id, cost))

    # Update year_built for assets that have been replaced
    asset_details <- asset_details %>% 
      mutate(year_built = ifelse(asset_id %in% actions[[year]]$asset_id,
                                 year,
                                 year_built))
  }

  # Combine all years worth of replacements into a single dataframe
  do.call(rbind, actions)
}