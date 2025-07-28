# This file contains default options for the annual_adjustment function type.


annual_adjustment_wrapper <- function(supplied_function,
                                      assets,
                                      asset_types,
                                      asset_actions,
                                      performed_actions,
                                      current_year) {
  "
  Enforces the requirements for the annual adjustment function type as laid out in docs/function.md
  "

  # Collect the number of rows of the assets table
  rows <- nrow(assets)

  # Collect the columns of the assets table
  columns <- colnames(assets)

  # Run function
  result <- supplied_function(assets,
                              asset_types,
                              asset_actions,
                              performed_actions,
                              current_year)
  
  # Assert that the results meets the assets table requirements
  # year_built must be less than or equal to current_year
  test_assets(result, asset_types, current_year + 1)
  
  # Assert that the number of rows of the assets table hasn't changed
  error_message <- paste("The number of rows of the assets table was changed by the function supplied for annual adjustment")
  if (rows != nrow(result)) {
    stop(error_message, call. = FALSE)
  }

  # Assert that the columns of the assets table hasn't changed
  columns_in_df(result, columns, "assets")

  # Return result
  result
}


replace_assets <- function(assets,
                           asset_types,
                           asset_actions,
                           performed_actions,
                           current_year) {
  "
  See docs/functions.md
  "

  # If there are no performed actions, then no replacements need to be made
  if (nrow(performed_actions) > 0) {

    # Get the subset of actions for the current year that are replacements
    replacements <- performed_actions %>% 
      left_join(asset_actions, by = "action_id") %>% 
      filter(replacement_flag == 1)

    # Update year_built for assets that have been replaced
    assets %>% 
      mutate(year_built = ifelse(asset_id %in% replacements$asset_id,
                                  current_year,
                                  year_built))

  } else {
    assets
  }



}