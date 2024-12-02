test_name = "Test 10: Constrained budget with non-replacement action"


# ---- Inputs ----

assets <- tibble(
  asset_id = c(0),
  asset_type_id = c(0),
  year_built = c(1995)
)

asset_types <- tibble(
  asset_type_id = c(0)
)

asset_actions <- tibble(
  action_id = c(0, 1),
  asset_type_id = c(0, 0),
  age_trigger = c(5, 10),
  cost = c(100, 500),
  replacement_flag = c(0, 1)
)

budgets <- tibble(
  budget_id = c(0),
  year = c(2000),
  budget = c(100)
)

budget_actions <- tibble(
  action_id = c(0, 1),
  budget_id = c(0, 0)
)

# Choose 2001 here to catch the error when non-replacement actions are duplcated for the 
# same asset
# Do not go all the way to 2005 as in test 5 because we don't need to test carryover here
start_year <- 2000
end_year <- 2001

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
    traditional_run(
      assets, 
      asset_types, 
      asset_actions, 
      budgets,
      budget_actions,
      start_year, 
      end_year, 
      cost_adjustment = cost_adjustment_dummy),
    tibble(
      year = c(2000),
      asset_id = c(0),
      asset_type_id = c(0),
      action_id = c(0),
      budget_id = c(0),
      cost = c(100)
    )
  )
})


# ---- Close ---

# Remove all objects to they don't affect subsequent tests
rm(list = c(
  "test_name",
  "assets",
  "asset_types",
  "asset_actions",
  "budgets",
  "budget_actions",
  "start_year",
  "end_year"
))
