# This file contains default options for the necessary_actions function type.
# These functions have access to every column in assets and asset_types and the year.
# They then return a subset of the input dataframe that is the assets that need
# replacement.


replace_by_age <- function(asset_details,
                           year) {
  "
  Parameters:
    asset_details - The result of left joining asset_types onto assets by asset_type_id.
      The year_built column should reflect any previous replacements made to assets by
      this model run.
    year - Current year

  Returns
    Returns a subset of asset_details where the age of the asset in year is greater than 
    or equal to the useful_life for its asset type.
  "
  asset_details %>% 
    filter(year - year_built >= useful_life)
}