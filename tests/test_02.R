test_name = "Test 2: 2 assets"


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
  action_id = c(0),
  asset_type_id = c(0),
  age_trigger = c(5),
  cost = c(100),
  replacement_flag = c(1)
)

budgets <- tibble(
  budget_id = c(0)
)

budget_years <- tibble(
  budget_id = c(0),
  year = c(2000),
  budget = c(1000)
)

budget_actions <- tibble(
  action_id = c(0),
  budget_id = c(0)
)

start_year <- 2000
end_year <- 2000


# ---- Test -----

test_that(test_name, {
  expect_equal(
    unconstrained(
      assets, 
      asset_types, 
      asset_actions, 
      start_year, 
      end_year
    )$performed_actions,
    tibble(
      year = c(2000, 2000),
      asset_id = c(0, 1),
      asset_type_id = c(0, 0),
      action_id = c(0, 0),
      cost = c(100, 100)
    )
  )
  expect_equal(
    traditional(
      assets, 
      asset_types, 
      asset_actions, 
      budgets,
      budget_years,
      budget_actions,
      start_year, 
      end_year
    )$performed_actions,
    tibble(
      year = c(2000, 2000),
      asset_id = c(0, 1),
      asset_type_id = c(0, 0),
      action_id = c(0, 0),
      budget_id = c(0, 0),
      cost = c(100, 100)
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
  "budget_years",
  "budget_actions",
  "start_year",
  "end_year"
))
