test_name = "Test 9: Skip large"


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
  action_id = c(0, 1),
  asset_type_id = c(0, 0),
  age_trigger = c(5, 10),
  cost = c(100, 50),
  replacement_flag = c(0, 1)
)

budgets <- tibble(
  budget_id = c(0),
  year = c(2000),
  budget = c(50)
)

budget_actions <- tibble(
  action_id = c(0, 1),
  budget_id = c(0, 0)
)

start_year <- 2000
end_year <- 2000


# ---- Test -----

# Note that skip_large is FALSE by default

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
      skip_large = FALSE),
    tibble()
  )
  expect_equal(
    traditional_run(
      assets, 
      asset_types, 
      asset_actions, 
      budgets,
      budget_actions,
      start_year, 
      end_year,
      skip_large = TRUE),
    tibble(
      year = c(2000),
      asset_id = c(0),
      asset_type_id = c(0),
      action_id = c(1),
      budget_id = c(0),
      cost = c(50)
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
