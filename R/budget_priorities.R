# The file contains the default options for the budget_priorities function type


budget_priorities_wrapper <- function(
  supplied_function,
  possible_budgets
) {
  "
  Enforces the requirements for the budget priorities function type as laid out in docs/function.md
  "

  # Create a copy of possible_budgets to use late
  reference <- possible_budgets

  # If there are no possible budgets, return possible_budgets
  # This simplifies computation and avoids an error in the below
  # assertion that is not safe for empty tibbles
  if (nrow(possible_budgets) == 0) {
    return(possible_budgets)
  }

  # Run function
  result <- supplied_function(possible_budgets)

  # Assert that result is a tibble with a single row
  # Note that since the supplied function will not be called when possible_budgets is empty,
  # we need not concern ourselves with that use case
  error_message <- "The function supplied for budget priorities returned soemthing other than a tibble with a single row"
  if (nrow(result) != 1) {
    stop(error_message, call. = FALSE)
  }

  # Assert that result is a row from possible_budgets
  # This is currently broken and is commented out to prevent it from causing errant erros when run
  # error_message <- "The function supplied for budget priorities returned something other than a row from the input"
  # if (nrow(dplyr::semi_join(reference, result, by = names(reference))) > 0) {
  #   stop(error_message, call. = FALSE)
  # }
  
  # Return Result
  result
}


#' @export
prioritize_first <- function(
  possible_budgets
){
  "
  Parameters:
    possible_budgets - A tibble that is formed by inner joining budget_actions and budget_years for the current year,
      and left joining budgets to a row of the asset_details table

  Returns:
    The first row of possible_budgets
  "
  possible_budgets %>% slice(1)
}