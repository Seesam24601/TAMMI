test_name = "Test 12: 2 budgets, each assigned to a different action"


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
  budget_id = c(0, 1)
)

budget_years <- tibble(
  budget_id = c(rep(0, 6), rep(1, 6)),
  year = c(2000:2005, 2000:2005),
  budget = rep(1000)
)

budget_actions <- tibble(
  action_id = c(0, 1),
  budget_id = c(0, 1)
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
    traditional_run(
      assets, 
      asset_types, 
      asset_actions, 
      budgets,
      budget_years,
      budget_actions,
      start_year, 
      end_year, 
      cost_adjustment = cost_adjustment_dummy
    )$performed_actions,
    tibble(
      year = c(2000, 2005),
      asset_id = c(0, 0),
      asset_type_id = c(0, 0),
      action_id = c(0, 1),
      budget_id = c(0, 1),
      cost = c(100, 500)
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
