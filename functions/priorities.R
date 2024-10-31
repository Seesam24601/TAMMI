# This file contains default options for the priorties function type
# These functions have access to every column in assets, asset_types, asset_actions, and the year.
# They accept a tibble with the necessary actions and return a rearrangement of that table
# The order that is returned is the order that the budget is applied


prioritize_longest_wait <- function(necessary_actions,
                                    current_year) {
  "
  Parameters:
    necessary_actions - The output of a function of the necessary_actions function type.
      The year_built column should reflect any previous replacements made to assets by
      this model run. The asset_actions should also have an age_trigger column
    curernt_year - Current year

  Returns:
    Rearrange necessary_actions so that it is ordered by longest time the action has been
    necessary. This is calculated by taking age_triger - (current_year - year_built)
  "

  # Assert asset_details has the age_trigger column
  columns_in_df(necessary_actions, "age_trigger", "asset_actions")

  necessary_actions

}