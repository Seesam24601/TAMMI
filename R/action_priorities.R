# This file contains default options for the priorties function type


action_priorities_wrapper <- function(
  supplied_function,
  necessary_actions,
  current_year
) {
  "
  Enforces the requirements for the action priorities function type as laid out in docs/function.md
  "

  # Create a copy of necessary_actions to use late
  reference <- necessary_actions

  # Run function
  result <- supplied_function(necessary_actions,
                              current_year)
  
  # Assert that result is a rearrangement of necessary_actions
  # Here the input version of necessary_actions is called reference
  # This is acheived by sorting by all columns and then checking that the results are identical
  reference_sorted <- reference %>% arrange(across(everything()))
  result_sorted <- result %>% arrange(across(everything()))
  error_message <- "The function supplied for action priorities returned something other than a rearrangement of the input"
  if (!identical(reference_sorted, result_sorted)) {
    stop(error_message, call. = FALSE)
  }
  
  # Return Result
  result
}


#' @export
prioritize_longest_wait <- function(
  necessary_actions,
  current_year
) {
  "
  See docs/functions.md
  "

  # Assert asset_details has the age_trigger column
  columns_in_df(necessary_actions, "age_trigger", "asset_actions")

  # Order by wait from longest to shortest
  necessary_actions %>% 
    mutate(wait = (current_year - year_built) - age_trigger) %>% 
    arrange(desc(wait)) %>% 

    # Remove extra column
    subset(select = -wait)

}


#' @export
priority_scores <- function(
  necessary_actions,
  current_year,
  priority_scores # priority scores is vector of the form (field = weight)
) {
  "
  TBD
  "

  # Assert asset_details has all of the fields used for priority scores
  columns_in_df(necessary_actions, names(priority_scores), "asset_actions")

  # Assert values for priority scores are numeric

  # Generate priority score for each necessary action
  # Then order from highest to lowest priority
  priority_score %>% 
    mutate(priority_score = rowSums(across(all_of(names(weights)), ~ .x * weights[cur_column()]))) %>% 
    arrange(desc(priority_score)) %>% 

    # Remove extra column
    subset(select = -priority_score)
}
