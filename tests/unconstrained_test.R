# This tests functions/unconstrained.R

library(tidyverse)
library(here)

source(here("models/unconstrained.R"))

# Load inputs
assets <- read_delim(here("tests/test_files/assets.csv"), show_col_types = FALSE)
asset_types <- read_delim(here("tests/test_files/asset_types.csv"), show_col_types = FALSE)

unconstrained(assets,
              asset_types,
              2000,
              2020)
