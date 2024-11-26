test_name = "Test 2: unconstrained run, 2 assets"


# ---- Setup ----

# Load libraries
library(tidyverse)
library(here)
library(testthat)

# Load model that is being tested 
source(here("models/unconstrained.R"))


# ---- Inputs ----

assets <- tibble(
  asset_id = c(0, 1),
  asset_type_id = c(0),
  year_built = c(1990, 1995)
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
end_year <- 2000


# ---- Test -----

test_that(test_name, {
  expect_equal(
    unconstrained_run(
      assets, 
      asset_types, 
      asset_actions, 
      start_year, 
      end_year),
    tibble(
      year = c(2000, 2000),
      asset_id = c(0, 1),
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
