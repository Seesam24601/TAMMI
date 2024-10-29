# This tests functions/traditional.R

library(tidyverse)
library(here)

source(here("models/traditional.R"))

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
budget <- read_delim(here("tests/test_files/budget.csv"),
                     col_types = "ii",
                     delim = ",")
traditional_actions <- read_delim(here("tests/test_files/traditional_actions.csv"),
                                  col_types = "iiiid",
                                  delim = ",")

# Run traditional model
results <- traditional_run(assets, asset_types, asset_actions, budget, 2000, 2020, skip_large = TRUE)

# Verify results
if (!identical(as_tibble(results), as_tibble(traditional_actions))) {
  stop("Traditional model is not functioning as intended")
}