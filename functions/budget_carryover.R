# This file contains the default options for the budget_carryover function type


carryover_all <- function(
  budgets,
  current_year,
  end_year
) {
  "
  See docs/functions.md
  "

  # Do not carryover if the current_year is the end_year because this may cause errors
  # when trying to select certain rows from the budgets table
  if (current_year != end_year) {

    # For the each budget, add any money remaining in current_year to current_year + 1
    budgets %>% 
      mutate(
        budget = if_else(
          year == current_year + 1,
          budget + budgets %>%
            filter(
              budget_id == budget_id,
              year == current_year
            ) %>% 
            pull(),
          budget
        )
      )
  } 
  
  # Otherwise, return budgets with no changes
  else {
    budgets
  }
}