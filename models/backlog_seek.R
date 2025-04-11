# This file contains the backlog_seek model

library(tidyverse)
library(here)

source(here("functions/preflight.R"))
source(here("functions/action_priorities.R"))
source(here("functions/annual_adjustment.R"))
source(here("functions/cost_adjustment.R"))
source(here("functions/necessary_actions.R"))


backlog_seek <- function(
  assets,
  asset_types,
  asset_actions,
  backlog,
  start_year,
  end_year,
  action_priorities = prioritize_longest_wait,
  annual_adjustment = replace_assets,
  cost_adjustment = inflation,
  necessary_actions = actions_by_age
) {
  "
  Parameters:
    assets - See docs/input_tables.md
    asset_types - See docs/input_tables.md
    asset_actions - See docs/input_tables.md
    backlog - See docs/input_table.md
    start_year - The first year the model calculates actions for. This should be an
      integer value. This should be <= end_year.
    end_year - That last year the model calculates actions for. This should be an
      integer value. This should >= start_year.
    action_priorities - See docs/functions.md
    annual_adjustment - See docs/functions.md
    budget_carryover - See docs/functions.md
    budget_priorities - See docs/functions.md
    cost_adjustment - See docs/dunctions.md
    necessary_actions - See docs/functions.md

  Returns:
    performed_actions - see output_tables.md 
    backlog - see output_tables.md
  This run aims to return the necessary spending to get a certain cost value in the backlog 
    for each year               
  "
}