# This file contains functions to check the assumptions of various models


is_integer <- function(x, variable_name) {
  "
  Parameters: 
    x
    variable_name - Name of x to be used in the error mesage if x is not an integer

  Returns:
    Nothing if x if round(x) == x is TRUE and does not throw an error. Otherwise, it 
    throws an error.
  "
  error_message <- paste(variable_name, "must be an integer")

  tryCatch({
    if (round(x) != x) {
      stop(error_message, call. = FALSE)
    }
  }, error = function(msg) {
      stop(error_message, call. = FALSE)
    })
}


is_integer_col <- function(col, df_name, col_name) {
  "
  Parameters: 
    col - Vector to be tested on
    df_name - Name of the dataframe to be used in the error message
    col_name - Name of the column to be used in the error mesage

  Returns:
    Nothing if x if round(x) == x is TRUE and does not throw an error for every element
    of col. Otherwise, it throws an error.
  "

  error_message <- paste("The", col_name, "field in", df_name, "cannot contain non-integer values")
  
  tryCatch({
    if (!all(sapply(col, (function(x) round(x) == x)))) {
      stop(error_message, call. = FALSE)
    }
  }, error = function(msg) {
    stop(error_message, call. = FALSE)
  })
}


test_assets <- function(assets) {

  # Assert year_built is integer-valued
  is_integer_col(assets$year_built, "assets", "year_built")
}


test_asset_types <- function(asset_types) {

  # Assert replacement_cost is integer-valued
  is_integer_col(asset_types$replacement_cost, "asset_types", "replacement_cost")

  # Assert useful_life is integer_valued
  is_integer_col(asset_types$useful_life, "asset_types", "useful_life")
}


year_order <- function(start_year, end_year) {
  "
  Parameters:
    start_year 
    end_year

  Returns:
    Nothing if both start_year <= end_year and both are intgers. Otherwise, it throughs
    an appropriate error
  "
  is_integer(start_year, "start_year")
  is_integer(end_year, "end_year")
  if (start_year > end_year) {
    stop("start_year cannot be greater than end_year")
  }
}