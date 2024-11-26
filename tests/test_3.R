test_name = "Test 3: unconstrained run, multiple years"


# ---- Setup ----

# Load libraries
library(tidyverse)
library(here)
library(testthat)

# Load model that is being tested 
source(here("models/unconstrained.R"))


# ---- Inputs ----

assets <- tibble(
  asset_id = c(0),
  asset_type_id = c(0),
  year_built = c(1990)
)

asset_types <- tibble(
  asset_type_id = c(0)
)

asset_actions <- tibble(
  asset_action_id = c(0),
  asset_type_id = c(0),
  age_trigger = c(5),
  cost = c(100),
  replacement_flag = c(1)
)

start_year <- 2000
end_year <- 2005

# Dummy function to ignore inflation
cost_adjustment_dummy <- function(
  asset_details,
  current_year,
  start_year
) {
  asset_details
}


# ---- Test -----

test_that(test_name, {
  expect_equal(
    unconstrained_run(
      assets, 
      asset_types, 
      asset_actions, 
      start_year, 
      end_year,
      cost_adjustment = cost_adjustment_dummy),
    tibble(
      year = c(2000, 2005),
      asset_id = c(0, 0),
      asset_type_id = c(0, 0),
      asset_action_id = c(0, 0),
      cost = c(100, 100)
    )
  )
})


# ---- Close ---

# Remove all objects to they don't affect subsequent tests
# Don't remove list of unit tests
rm(list = setdiff(ls(), "unit_tests"))
