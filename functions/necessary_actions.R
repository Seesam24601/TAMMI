# This file contains default options for the necessary_actions function type.
# These functions have access to every column in assets and asset_types and the year.
# They then return a subset of the input dataframe that is the assets that need
# replacement.


replace_by_age <- function(asset_details,
                           previous_actions,
                           year) {
  "
  Parameters:
    asset_details - The result of left joining asset_types abd asset_cations onto assets by asset_type_id.
      The year_built column should reflect any previous replacements made to assets by
      this model run.
    previous_actions - All actions that have been allocated in previous years. Must meet the same criteria 
      as the performed_actions table type
    year - Current year

  Returns
    Returns a subset of asset_details where the age of the asset in year is greater than 
    or equal to the useful_life for its asset type.
  "

  # Assert asset_details has the age_trigger column
  columns_in_df(asset_details, "age_trigger", "asset_actions")


  previous_actions %>% 

    # Ignore previous replacements
    filter(!replacement_flag) %>% 

    # Only look at the most recent action for each combination of asset and action
    group_by(asset_id, asset_action_id) %>% 
    filter(year == max(year)) %>% 
    ungroup() %>% 

    subset(select = c(asset_id, asset_action_id, ))
    right_join(asset_details, by =  c("asset_id", "asset_action_id")) %>% 
    
    # Remove actions tht occurred before the replacement year
    # These were actions on the previous version of the asset
    filter(year < year_built) %>% 

    # Only keep actions for assets who are older than the age_trigger
    filter(year - year_built >= age_trigger) %>% 
    
    subset(select -c(year, ))
}