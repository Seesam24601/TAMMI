# TAMMI

The Transit Asset Management Modelling Initiative, or TAMMI, is meant to be a replacement for TERM Lite.

- The `docs` folder contains additional information about how to use this software. In particularly, `models.md` goes over the different model options and `input_tables` and `output_tables` shows what goes into and our of each model
- The `functions` folder contains the default values for the user supplied functions (see `docs/functions.md`) as well as `preflight.R` which contains type safety checks used by the models
- The `models` folder contains the individual models themselves
- The `tests` folder contains tests used to test that the software works as intended. Run `all_tests.R` to verify this
