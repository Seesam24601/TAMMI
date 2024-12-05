# The file contains the default options for the budget_priorities function type


prioritize_first <- function(
  possible_budgets
){
  "
  Parameters:
    possible_budgets - A tibble that is formed by left joining budget_actions, and then budgets to a row
      of the asset_details table

  Returns:
    The first row of possible_budgets
  "
  possible_budgets %>%  slice(1)
}