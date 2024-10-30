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

# Load test results
traditional_actions_one <- read_delim(here("tests/test_files/traditional_actions_one.csv"),
                                      col_types = "iiiid",
                                      delim = ",")
traditional_actions_two <- read_delim(here("tests/test_files/traditional_actions_two.csv"),
                                      col_types = "iiiid",
                                      delim = ",")

# Run traditional model
results_one <- traditional_run(assets, asset_types, asset_actions, budget, 2000, 2022, skip_large = TRUE, carryover = FALSE)
results_two <- traditional_run(assets, asset_types, asset_actions, budget, 2000, 2022, skip_large = FALSE, carryover = FALSE)

# Verify results
if (!identical(as_tibble(results_one), as_tibble(traditional_actions_one))) {
  stop("Traditional model is not functioning as intended: test 1")
}
if (!identical(as_tibble(results_one), as_tibble(traditional_actions_one))) {
  stop("Traditional model is not functioning as intended: test 2")
}