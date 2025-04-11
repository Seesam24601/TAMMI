test_name = "Test 14: Simplest backlog seek"

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

sought_backlog <- tibble(
  year = c(2000),
  backlog = c(0)
)

start_year <- 2000
end_year <- 2000


# ---- Test -----

test_that(test_name, {
  expect_equal(
    backlog_seek(
      assets, 
      asset_types, 
      asset_actions, 
      sought_backlog,
      start_year, 
      end_year
    )$performed_actions,
    tibble(
      year = c(2000),
      asset_id = c(0),
      asset_type_id = c(0),
      action_id = c(0),
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
  "sought_backlog",
  "start_year",
  "end_year"
))
