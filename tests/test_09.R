test_name = "Test 9: Skip large"


# ---- Inputs ----

assets <- tibble(
  asset_id = c(0),
  asset_type_id = c(0),
  year_built = c(1990),
  quantity = c(1)
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
  budget_id = c(0)
)

budget_years <- tibble(
  budget_id = c(0),
  year = c(2001),
  budget = c(50)
)

budget_actions <- tibble(
  action_id = c(0, 1),
  budget_id = c(0, 0)
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

# Note that skip_large is FALSE by default

test_that(test_name, {
  expect_equal(
    nrow(traditional(
      assets, 
      asset_types, 
      asset_actions, 
      budgets,
      budget_years,
      budget_actions,
      start_year, 
      end_year,
      skip_large = FALSE,
      cost_adjustment = cost_adjustment_dummy
    )$performed_actions),
    0
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
      end_year,
      skip_large = FALSE,
      cost_adjustment = cost_adjustment_dummy
    )$backlog,
    tibble(
      year = c(2000, 2000, 2001, 2001),
      asset_id = c(0, 0, 0, 0),
      asset_type_id = c(0, 0, 0, 0),
      action_id = c(0, 1, 0, 1),
      cost = c(100, 50, 100, 50)
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
      end_year,
      skip_large = TRUE,
      cost_adjustment = cost_adjustment_dummy
    )$performed_actions,
    tibble(
      year = c(2001),
      asset_id = c(0),
      asset_type_id = c(0),
      action_id = c(1),
      budget_id = c(0),
      cost = c(50)
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
      end_year,
      skip_large = TRUE,
      cost_adjustment = cost_adjustment_dummy
    )$backlog,
    tibble(
      year = c(2000, 2000, 2001),
      asset_id = c(0, 0, 0),
      asset_type_id = c(0, 0, 0),
      action_id = c(0, 1, 0),
      cost = c(100, 50, 100)
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
