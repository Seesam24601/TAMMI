test_name = "Test 6: Inflation"


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
  action_id = c(0),
  asset_type_id = c(0),
  age_trigger = c(5),
  cost = c(100),
  replacement_flag = c(1)
)

budgets <- tibble(
  budget_id = rep(0),
  year = 2000:2005,
  budget = rep(1000)
)

budget_actions <- tibble(
  action_id = c(0),
  budget_id = c(0)
)

start_year <- 2000
end_year <- 2005


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
      year = c(2000, 2005),
      asset_id = c(0, 0),
      asset_type_id = c(0, 0),
      action_id = c(0, 0),
      cost = c(100, 116)
    ),
    tolerance = 0.001
  )
  expect_equal(
    traditional_run(
      assets, 
      asset_types, 
      asset_actions, 
      budgets,
      budget_actions,
      start_year, 
      end_year),
    tibble(
      year = c(2000, 2005),
      asset_id = c(0, 0),
      asset_type_id = c(0, 0),
      action_id = c(0, 0),
      budget_id = c(0, 0),
      cost = c(100, 116)
    ),
    tolerance = 0.001
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
