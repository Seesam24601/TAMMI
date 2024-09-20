# This file contains the unconstrained_run functions
# This file is tested by tests/unconstrained_test.R

library(tidyverse)
library(here)

source(here("functions/preflight.R"))


# ---- unconstrained ----
unconstrained <- function(assets,
                          asset_types,
                          start_year,
                          end_year) {
  "
  Parameters:
    assets - Dataframe containing one row for every asset. It must have the following
      fields:
        > asset_it: Must be unique
        > asset_type_id: Must be present in asset_types$asset_type_id
        > year_built: Year the asset was created. This is used to calculate the age of 
            the asset. Cannot be greater than or equal to start_year. Must be an integer
            value.
    asset_types - Dataframe containing one row for each type of asset. It must have the
      following fields:
        > asset_types_id: Must be unique
        > useful_life: The age in years that the asset must be replacement. Must be an
            integer value
        > replacement_cost: The cost to replace the asset in US dollars. Must be an
            integer value.
    start_year - The first year the model calculates actions for. This should be an
      integer value. This should be <= end_year.
    end_year - That last year the model calculates actions for. This should be an
      integer value. This should >= start_year.

  Returns:
  "
  
  # Assert that the assets dataframe meets its requirements

  # Assert that the asset_types dataframe meets its requirements

  # Assert that start_year and end_year and integers and start_year <= end_year
  year_order(start_year, end_year)


}