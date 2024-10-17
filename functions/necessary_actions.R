# This file contains default options for the necessary_actions function type.
# These functions have access to every column in assets and asset_types and the year.
# They then return a subset of the input dataframe that is the assets that need
# replacement.


replace_by_age <- function(asset_details,
                           previous_actions,
                           current_year) {
  "
  Parameters:
    asset_details - The result of left joining asset_types abd asset_cations onto assets by asset_type_id.
      The year_built column should reflect any previous replacements made to assets by
      this model run.
    previous_actions - All actions that have been allocated in previous years. Must meet the same criteria 
      as the performed_actions table type
    current_year - Current year

  Returns
    Returns a subset of asset_details where the age of the asset in year is greater than 
    or equal to the useful_life for its asset type.
  "

  # Assert asset_details has the age_trigger column
  columns_in_df(asset_details, "age_trigger", "asset_actions")

  # Only keep actions for assets who are older than the age_trigger
  # If there are no previous actions, nothing else is needed
  if(is.null(previous_actions)) {

    asset_details %>% 
      filter(current_year - year_built >= age_trigger)

  } else {

    pr <- previous_actions %>% 
      
      # Combine with asset_details
      subset(select = c(asset_id, asset_action_id, year)) %>%
      left_join(asset_details, by =  c("asset_id", "asset_action_id")) %>% 

      # Remove actions tht occurred before the replacement year
      # These were actions on the previous version of the asset
      filter(year >= year_built) %>% 
      
      # Join all asset actions in
      # The above should include all actions taken on the current version of 
      # each asset_id. This then adds all aditional actions that have not
      # yet been taken.
      subset(select = c(asset_id, asset_action_id, year)) %>%
      right_join(asset_details, by =  c("asset_id", "asset_action_id")) %>% 
      
      # Any actions that have a year associated with them mean that 
      # they have already been taken for a given asset_id on a given
      # replacement
      filter(is.na(year))
    
    # print(current_year)
    # print(pr)
    # print(" ")

    previous_actions %>% 

      # Combine with asset_details
      subset(select = c(asset_id, asset_action_id, year)) %>%
      left_join(asset_details, by =  c("asset_id", "asset_action_id")) %>% 

      # Remove actions tht occurred before the replacement year
      # These were actions on the previous version of the asset
      filter(year >= year_built) %>% 
      
      # Join all asset actions in
      # The above should include all actions taken on the current version of 
      # each asset_id. This then adds all aditional actions that have not
      # yet been taken.
      subset(select = c(asset_id, asset_action_id, year)) %>%
      right_join(asset_details, by =  c("asset_id", "asset_action_id")) %>% 
      
      # Any actions that have a year associated with them mean that 
      # they have already been taken for a given asset_id on a given
      # replacement
      filter(is.na(year)) %>% 

      # Only keep actions for assets who are older than the age_trigger
      filter(current_year - year_built >= age_trigger) %>% 
    
      subset(select = -c(year))
    
  }
}