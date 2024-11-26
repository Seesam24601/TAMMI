test_name = "Test 6: inflation"


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

budget <- tibble(
  year = 2000:2005,
  budget = rep(1000)
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
      asset_action_id = c(0, 0),
      cost = c(100, 116)
    ),
    tolerance = 0.001
  )
  expect_equal(
    traditional_run(
      assets, 
      asset_types, 
      asset_actions, 
      budget,
      start_year, 
      end_year),
    tibble(
      year = c(2000, 2005),
      asset_id = c(0, 0),
      asset_type_id = c(0, 0),
      asset_action_id = c(0, 0),
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
  "budget",
  "start_year",
  "end_year"
))
