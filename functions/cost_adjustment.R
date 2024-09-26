# This file contains default options for the cost_adjustment function type.
# These functions have access to every column in assets and asset_types the year, and
# start_year.
# The update the replacement_cost column to adjustment for things like inflation and
# agency soft costs.


inflation <- function(asset_details,
                      year,
                      start_year,
                      inflation_rate = 0.03) {
  "
  Parameters:
    asset_details - The result of left joining asset_types onto assets by asset_type_id.
      The year_built column should reflect any previous replacements made to assets by
      this model run.
    year - Current year. Must be greated than start_year
    start_year - Year the model started on. This is considered the base year for
      inflation calculations. All costs should be listed in dollars for that year
    inflation_rate - 0.03 by default

  Returns
    The asset_details dataframe with the replacement_cost column updated to reflect the
    inflation that is expected to occur between year and start_year. Inflation is 
    calculated as occuring at inflation_rate starting at start_year and compounding
    annually. The results are rounded to two decimal places.
  "

  # Assert that start_year and year are both integer-valued and that year >= start_year
  year_order(start_year, year)

  asset_details %>% 
    mutate(cost = round(cost * (1 + inflation_rate)^(year - start_year), 2))
}