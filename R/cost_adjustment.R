# This file contains default options for the cost_adjustment function type.


cost_adjustment_wrapper <- function(supplied_function,
                                    asset_details,
                                    current_year,
                                    start_year) {
  "
  Enforces the requirements for the cost adjustment function type as laid out in docs/function.md
  "
  
  # Collect the number of rows of the asset_details table
  rows <- nrow(asset_details)

  # Collect the columns of the asset_details table
  columns <- colnames(asset_details)

  # Collect every part of the asset_details table except the cost column
  reference <- asset_details %>% 
    subset(select = -cost)

  # Run function
  result <- supplied_function(asset_details,
                              current_year,
                              start_year)

  # Assert that the number of rows of the asset_details table hasn't changed
  error_message <- paste("The number of rows of the asset_details table was changed by the function supplied for cost adjustment")
  if (rows != nrow(result)) {
    stop(error_message, call. = FALSE)
  }

  # Assert that the columns of the asset details table hasn't changed
  columns_in_df(result, columns, "asset_details")

  # Assert that every part of the asset_details table except the cost column hasn't been changed
  error_message <- paste("Part of the asset_details other than the cost column have been changed by the function supplied for cost adjustment")
  if (!identical(reference, result %>%  subset(select = -cost))) {
    stop(error_message, call. = FALSE)
  }

  # Assert that the cost field is still non-negative
  is_non_negative_col(asset_details$cost, "asset_details", "cost")

  # Return result
  result
}


#' @export
inflation <- function(asset_details,
                      current_year,
                      start_year,
                      inflation_rate = 0.03) {
  "
  See docs/functions.md
  "

  # Assert that start_year and year are both integer-valued and that year >= start_year
  year_order(start_year, current_year)

  asset_details %>% 
    mutate(cost = cost * (1 + inflation_rate)^(current_year - start_year))
}