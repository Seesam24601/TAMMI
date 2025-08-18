test_name = "Test 16: Backlog seek by percent"

# ---- Inputs ----

assets <- tibble(
  asset_id = c(0, 1, 2),
  asset_type_id = c(0, 1, 2),
  year_built = c(1990, 1990, 1990)
)

asset_types <- tibble(
  asset_type_id = c(0, 1, 2)
)

asset_actions <- tibble(
  action_id = c(0, 1, 2),
  asset_type_id = c(0, 1, 2),
  age_trigger = c(5, 6, 7),
  cost = c(70, 20, 10),
  replacement_flag = c(1, 1, 1)
)

backlog_sought <- tibble(
  year = c(2001, 2002, 2003),
  backlog = c(0.5, 0.25, 0)
)

start_year <- 2000
end_year <- 2003

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
    backlog_seek(
      assets, 
      asset_types, 
      asset_actions, 
      backlog_sought,
      start_year, 
      end_year,
      cost_adjustment = cost_adjustment_dummy,
      proportion = TRUE
    )$performed_actions,
    tibble(
      year = c(2001, 2002, 2003),
      asset_id = c(0, 1, 2),
      asset_type_id = c(0, 1, 2),
      action_id = c(0, 1, 2),
      cost = c(70, 20, 10)
    )
  )
  expect_equal(
    backlog_seek(
      assets, 
      asset_types, 
      asset_actions, 
      backlog_sought,
      start_year, 
      end_year,
      cost_adjustment = cost_adjustment_dummy,
      proportion = TRUE
    )$backlog,
    tibble(
      year = c(2000, 2000, 2000, 2001, 2001, 2002),
      asset_id = c(0, 1, 2, 1, 2, 2),
      asset_type_id = c(0, 1, 2, 1, 2, 2),
      action_id = c(0, 1, 2, 1, 2, 2),
      cost = c(70, 20, 10, 20, 10, 10)
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
  "backlog_sought",
  "start_year",
  "end_year"
))
