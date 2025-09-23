test_name = "Test 18: Priority Scores"

# ---- Inputs ----

assets <- tibble(
  asset_id = c(0),
  asset_type_id = c(0),
  year_built = c(1990),
  quantity = c(2)
)

asset_types <- tibble(
  asset_type_id = c(0)
)

asset_actions <- tibble(
  action_id = c(0, 1),
  asset_type_id = c(0, 0),
  age_trigger = c(5, 5),
  cost = c(100, 200),
  replacement_flag = c(0, 0),
  a = c(1, 4),
  b = c(3, 1)
)

budgets <- tibble(
  budget_id = c(0)
)

budget_years <- tibble(
  budget_id = c(0),
  year = c(2001),
  budget = c(200)
)

budget_actions <- tibble(
  action_id = c(0),
  budget_id = c(0)
)

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
    traditional(
      assets, 
      asset_types, 
      asset_actions, 
      budgets,
      budget_years,
      budget_actions,
      start_year, 
      end_year,
      action_priorities = function(...)(priority_scores(priority_scores = c(a = 0.5, b = 0.5), ...)),
      cost_adjustment = cost_adjustment_dummy
    )$performed_actions,
    tibble(
      year = c(2001),
      asset_id = c(0),
      asset_type_id = c(0),
      action_id = c(0),
      budget_id = c(0),
      cost = c(200)
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
