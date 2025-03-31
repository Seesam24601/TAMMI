# This file contains the default options for the budget_carryover function type

# Note to self. Cannot use budget_years_detailed because it creates weird duplicating behavior when resent to budget_years
# Must correct


budget_carryover_wrapper <- function(
  supplied_function,
  budget_years_detailed,
  current_year
) {
  "
  Enforces the requirements for the budget priorities function type as laid out in docs/function.md
  "

  # Create a copy of possible_budgets to use late
  reference <- budget_years_detailed

  # Run function
  result <- supplied_function(budget_years_detailed, current_year)

  # Assert that only the budget field for the current year changed
  # Create a temproary field to avoid comparing the budget in the year that has changed
  reference <- reference %>% 
    mutate(budget_modified = if_else(year == current_year + 1, 0, budget))
  result <- result %>% 
    mutate(budget_modified = if_else(year == current_year + 1, 0, budget))
  error_message <- "The function supplied for budget carryover changed something other than the budget field of the next year"
  if (!identical(reference %>%  subset(select = -budget), result %>%  subset(select = -budget))) {
    stop(error_message, call. = FALSE)
  }
  result <- result %>% 
    subset(select = -budget_modified)

  # Assert that the budgets field of the result is integer-valued
  is_integer(result$budget, "The budget field of the result of function supplied for budget carryover")
  
  # Return Result
  result
}


carryover_all <- function(
  budget_years_detailed,
  current_year
) {
  "
  See docs/functions.md
  "

  # For the each budget, add any money remaining in current_year to current_year + 1
  budget_years_detailed %>% 
    mutate(
      budget = if_else(
        year == current_year + 1,
        budget + budget_years_detailed %>%
          filter(
            budget_id == budget_id,
            year == current_year
          ) %>% 
          pull(),
        budget
      )
    )
  
}