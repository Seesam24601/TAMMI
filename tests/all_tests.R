# This script runs all unit tests

# Load libraries
library(tidyverse)
library(here)
library(testthat)

# Load models
source(here("models/unconstrained.R"))
source(here("models/traditional.R"))

# Get all unit tests
unit_tests <- list.files(path = here("tests"), pattern = "^test.*\\.R$", full.names = TRUE)

# Run each unit test
lapply(unit_tests, source)

# Cleanup
rm(list = ls())