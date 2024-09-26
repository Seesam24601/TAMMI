# This tests functions/unconstrained.R

library(tidyverse)
library(here)

source(here("models/unconstrained.R"))

# Load inputs
assets <- read_delim(here("tests/test_files/assets.csv"), 
                     col_types = "iii",
                     delim = ",")
asset_types <- read_delim(here("tests/test_files/asset_types.csv"), 
                          col_types = "i",
                          delim = ",")
asset_actions <- read_delim(here("tests/test_files/asset_actions.csv"),
                            col_types = "iiiii",
                            delim = ",")
unconstrained_actions <- read_delim(here("tests/test_files/unconstrained_actions.csv"),
                                    col_types = "iiiid",
                                    delim = ",")

# Run unconstrained model
results <- unconstrained(assets, asset_types, asset_actions, 2000, 2020)

# Verify results
if (!identical(as_tibble(results), as_tibble(unconstrained_actions))) {
  stop("Unconstrained model is not functioning as intended")
}
