# This file contains the unconstrained_run functions
# This file is tested by tests/unconstrained_test.R

library(tidyverse)
library(here)


# ---- unconstrained ----
unconstrained <- function(asset_file_path = "inputs/assets.csv",
                          asset_type_file_path = "inputs/asset_types.csv") {
  "
  Parameters:
    asset_file_path - File path to the location of the assets CSV file. This is 
      inputs/assets.csv by default. File path should be relative to the TAMMI folder.
    asset_type_file_path - File path to the location of the asset types CSV file. This is 
      inputs/asset_types.csv by default. File path should be relative to the TAMMI 
      folder.

  Returns:
  "

  # Load inputs
  assets <- read_delim(here(asset_file_path), show_col_types = FALSE)
  asset_types <- read_delim(here(asset_type_file_path), show_col_types = FALSE)


}