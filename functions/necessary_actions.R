# This file contains default options for the necessary_actions function type.


necessary_actions_wrapper <- function(supplied_function,
                                      asset_details,
                                      previous_actions,
                                      current_year) {
  "
  Enforces the requirements for the necessary actions function type as laid out in docs/function.md
  "

  # Collect the columns of the asset_details table
  columns <- colnames(asset_details)

  # Run function
  result <- supplied_function(asset_details,
                              previous_actions,
                              current_year)
  
  # Assert that the columns of the asset details table hasn't changed
  columns_in_df(result, columns, "asset_details")
  
  # Return result
  result
}


actions_by_age <- function(asset_details,
                           previous_actions,
                           current_year) {
  "
  See docs/functions.md
  "

  # Assert asset_details has the age_trigger column
  columns_in_df(asset_details, "age_trigger", "asset_actions")

  # Only keep actions for assets who are older than the age_trigger
  # If there are no previous actions, nothing else is needed
  if(is.null(previous_actions)) {

    asset_details %>% 
      filter(current_year - year_built >= age_trigger)

  } else {

    previous_actions %>% 

      # Combine with asset_details
      subset(select = c(asset_id, asset_action_id, year)) %>%
      left_join(asset_details, by =  c("asset_id", "asset_action_id")) %>% 

      # Remove actions tht occurred before the replacement year
      # These were actions on the previous version of the asset
      # This must be strictly greater, otherwise replacements will not be
      # repeated
      filter(year > year_built) %>%  
      
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