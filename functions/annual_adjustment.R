# This file contains default options for the annual_adjustment function type.
# These functions have access to every column in assets, asset_types, and asset_actions tables, the
# current_year, and the performed_actions for the current_uear
# They provide annual updates to the assets so that things like year_built can be update with replacements
# Note that only fields in the assets table should be altered


replace_assets <- function(assets,
                           asset_types,
                           asset_actions,
                           performed_actions,
                           current_year) {
  "
  Parameters:
    assets - See input_tables.md
    asset_types - See input_tables.md
    asset_actions - See input_tables.md
    performed_actions - Tibble with the subset of asset_details that will be performed in the current_year
    current_year - Integer-valued current year
  
  Returns:
    The assets table with the year_built column replaced for every asset with an action in performed_actions 
    where replacement_flag is 1
  "
  
}