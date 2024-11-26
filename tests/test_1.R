test_name = "Test 1: unconstrained run, 1 asset"


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
  age_trigger = c(0),
  cost = c(100),
  replacement_flag = c(1)
)

start_year <- 2000
end_year <- 2000


# ---- Test -----

# Run model
performed_actions <- unconstrained_run(assets, asset_types, asset_actions, start_year, end_year)

# Desired result
expected_performed_actions <- tibble(
  year = c(2000),
  asset_id = c(0),
  asset_type_id = c(0),
  asset_action_id = c(0),
  cost = c(100)
)

# Test that result is as expected
test_that(test_name, {
  expect_equal(performed_actions, expected_performed_actions)
})


