# This file contains default options for the priorties function type


prioritize_longest_wait <- function(necessary_actions,
                                    current_year) {
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