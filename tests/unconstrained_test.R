# This tests functions/unconstrained.R

library(here)

source(here("models/unconstrained.R"))

unconstrained(asset_file_path = "tests/test_files/assets.csv",
              asset_type_file_path = "tests/test_files/asset_types.csv")
