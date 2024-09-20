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
    assets
    asset_types
    start_year - The first year the model calculates actions for. This should be an
      integer value. This should be <= end_year.
    end_year - That last year the model calculates actions for. This should be an
      integer value. This should >= start_year.

  Returns:
  "

  # Assert that start_year and end_year and integers and start_year <= end_year
  year_order(start_year, end_year)


}