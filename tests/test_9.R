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
  asset_action_id = c(0, 1),
  asset_type_id = c(0, 0),
  age_trigger = c(5, 10),
  cost = c(100, 50),
  replacement_flag = c(0, 1)
)

budget <- tibble(
  year = c(2000),
  budget = c(50)
)

start_year <- 2000
end_year <- 2000


# ---- Test -----

test_that(test_name, {
  expect_equal(
    traditional_run(
      assets, 
      asset_types, 
      asset_actions, 
      budget,
      start_year, 
      end_year),
    tibble(
      year = numeric(0),
      asset_id = numeric(0),
      asset_type_id = numeric(0),
      asset_action_id = numeric(0),
      cost = numeric(0)
    )
  )
  expect_equal(
    traditional_run(
      assets, 
      asset_types, 
      asset_actions, 
      budget,
      start_year, 
      end_year,
      skip_large = TRUE,
      carryover = FALSE),
    tibble(
      year = c(2000),
      asset_id = c(0),
      asset_type_id = c(0),
      asset_action_id = c(1),
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
  "budget",
  "start_year",
  "end_year"
))
