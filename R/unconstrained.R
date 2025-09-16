# This file contains the unconstrained model


# ---- unconstrained ----
unconstrained<- function(
  assets,
  asset_types,
  asset_actions,
  start_year,
  end_year,
  necessary_actions = actions_by_age,
  cost_adjustment = inflation,
  annual_adjustment = replace_assets
) {
  "
  See functions/models.md
  "
  
  # Assert that start_year and end_year and integers and start_year <= end_year
  year_order(start_year, end_year)

  # Assert that the asset_types dataframe meets its requirements
  test_asset_types(asset_types)

  # Assert that the assets dataframe meets its requirements
  test_assets(assets, asset_types, start_year)

  # Assert that asset_actions dataframe meets its requirements
  test_asset_actions(asset_actions, asset_types)

  # Create empty tibbles with the correct fields for each year in actions and backlog
  # This prevents errors where there are years with no actions and/or no backlog
  # Use as.character here because numbers cannot be keys in lists within R
  fields <- c("year", "asset_id", "asset_type_id", "action_id", "cost")
  actions <- set_names(map(as.character(start_year:end_year), ~ tibble(!!!set_names(rep(list(integer()), length(fields)), fields))), as.character(start_year:end_year))
  backlog <- set_names(map(as.character(start_year:end_year), ~ tibble(!!!set_names(rep(list(integer()), length(fields)), fields))), as.character(start_year:end_year))

  # For each year between start_year and end_year (including both), note every asset
  # that needs to be replaced and update its value in asset_details
  for (current_year in start_year:end_year){

    # Left join asset_types and asset_actions on to assets
    asset_details <- assets %>% 
      left_join(asset_types, by = "asset_type_id") %>% 
      left_join(asset_actions, by = "asset_type_id", relationship = "many-to-many")

    # Get the subset of assets that need to be replaced in year
    previous_actions <- do.call(bind_rows, actions)
    
    # Get a list of replacements that need to be made in year
    prioritized_necessary_actions <- asset_details %>% 
    
      necessary_actions_wrapper(necessary_actions, ., previous_actions, current_year) %>% 
      
      # Apply cost adjustments
      cost_adjustment_wrapper(cost_adjustment, ., current_year, start_year) %>% 

      # Add the year of the replacement as a column
      mutate(year = current_year) %>% 
      
      subset(select = c(year, asset_id, asset_type_id, action_id, cost))
    
    # If the current_year is the start_year, then no actions are performed; 
    # otherwise alla ctions are performed
    # This is to keep the model consistent with other models and TERM Lite
    # Use slice(0) to create an empty tibble with the same fields
    if (current_year == start_year) {
      backlog[[as.character(current_year)]] <- prioritized_necessary_actions 
    } else {
      actions[[as.character(current_year)]] <- prioritized_necessary_actions 
    }

    # Perform annual adjustments
    assets <- annual_adjustment_wrapper(
      annual_adjustment,
      assets, 
      asset_types, 
      asset_actions, 
      actions[[as.character(current_year)]], 
      current_year
    )
  }

  # Create a single object with all the results
  result <- list(
    performed_actions = do.call(bind_rows, actions),
    backlog = do.call(bind_rows, backlog)
  )

  class(result) <- "unconstrained_tammi_model"

  return(result)
}