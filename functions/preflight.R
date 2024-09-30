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


is_flag_col <- function(col, df_name, col_name) {
  "
  Parameters: 
    col - Vector to be tested on
    df_name - Name of the dataframe to be used in the error message
    col_name - Name of the column to be used in the error mesage

  Returns:
    Nothing if every element of col is either 0 or 1. Otherwise, it throws an error.
  "
  error_message <- paste("The", col_name, "field in", df_name, "contains a value other than 0 or 1")
  
  if (!identical(unique(col), c(0L, 1L)) & !identical(unique(col), 0L)  & !identical(unique(col), 1L) ) {
    stop(error_message, call. = FALSE)
  }
}


is_unique_col <- function(col, df_name, col_name) {
  "
  Parameters: 
    col - Vector to be tested on
    df_name - Name of the dataframe to be used in the error message
    col_name - Name of the column to be used in the error mesage

  Returns:
    Nothing if every element of col is unique. Throws an error otherwise.
  "
  error_message <- paste("The", col_name, "field in", df_name, "must be unique")
  
  if(length(col) != length(unique(col))){
    stop(error_message, call. = FALSE)
  }
}


key_exists <- function(keys, valid_keys, df1_name, df2_name, col_name) {
  "
  Parameters:
    keys - Vector of keys that should be in valid_keys
    valid_keys - Vector of valid keys
    df1_name - Name of the dataframe that contains keys
    df2_name - Name of the dataframe that contains valid_keys
    col_name - Name of the column in df1_name that contains keys and the column in
      df2_name that contains valid_keys

  Returns:
    Nothing if every element of keys is in valid_keys. Throws an error otherwise
  "
  error_message <- paste("Not all values in", col_name, "in", df1_name, "are present in", col_name, "in", df2_name)

  if (!all(keys %in% valid_keys)) {
    stop(error_message, call. = FALSE)
  }

}


test_asset_actions <- function(asset_actions, asset_types) {
  "
  Parameters:
    asset_actions 
    asset_types (passed preflight)

  Returns:
    Nothing if assets meets its assumptions. Throws an appropriate error otherwise.
  "

  # Assert required columns exist
  error_message <- "The asset_actions table is missing one of the following required columns: asset_action_id, asset_type_id, cost, replacement_flag"
  if (!all(c("asset_action_id", "asset_type_id", "cost", "replacement_flag") %in% colnames(asset_actions))) {
    stop(error_message, call. = FALSE)
  }
  
  # Assert asset_action_id is unique
  is_unique_col(asset_actions$asset_action_id, "asset_actions", "asset_actions_id")

  # Assert asset_type_id is in asset_types
  key_exists(asset_actions$asset_type_id, 
    asset_types$asset_type_id,
    "asset_actions",
    "asset_types",
    "asset_type_id")
  
  # Assert cost is integer-valued
  is_integer_col(asset_actions$cost, "asset_actions", "cost")

  # Assert replacement_flag is a flag
  is_flag_col(asset_actions$replacement_flag, "asset_actions", "replacement_flag")

}


test_assets <- function(assets, asset_types, start_year) {
  "
  Parameters:
    assets 
    asset_types (passed preflight)
    start_year (passed preflight)

  Returns:
    Nothing if assets meets its assumptions. Throws an appropriate error otherwise.
  "

  # Assert required columns exist
  error_message <- "The assets table is missing one of the following required columns: asset_id, asset_type_id, year_built"
  if (!all(c("asset_id", "asset_type_id", "year_built") %in% colnames(assets))) {
    stop(error_message, call. = FALSE)
  }

  # Assert asset_id is unique
  is_unique_col(assets$asset_id, "assets", "asset_id")

  # Assert asset_type_id is in asset_types
  key_exists(assets$asset_type_id, 
             asset_types$asset_type_id,
             "assets",
             "asset_types",
             "asset_type_id")

  # Assert year_built is integer-valued
  is_integer_col(assets$year_built, "assets", "year_built")

  # Assert year_built < start_year
  error_message <- "Not all values in year_built in assets are strictly less than start_year"
  if (!all(assets$year_built < start_year)) {
    stop(error_message, call. = FALSE)
  }
}


test_asset_types <- function(asset_types) {
  "
  Parameters:
    asset_types

  Returns:
    Nothing if asset_types meets its assumptions. Throws an appropriate error otherwise.
  "

  # Assert asset_type_id column exists
  error_message <- "The asset_types table is missing one of the following required columns: asset_type_id"
  if (!("asset_type_id" %in% colnames(asset_types))) {
    stop(error_message, call. = FALSE)
  }

  # Assert asset_type_id is unique
  is_unique_col(asset_types$asset_type_id, "asset_types", "asset_type_id")

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