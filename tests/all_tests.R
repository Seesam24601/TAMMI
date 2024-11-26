# This script runs all unit tests

# Load libraries
library(tidyverse)
library(here)

# Get all unit tests
unit_tests <- list.files(path = here("tests"), pattern = "^test.*\\.R$", full.names = TRUE)

# Run each unit test
lapply(unit_tests, source)

# Cleanup
rm("unit_tests")