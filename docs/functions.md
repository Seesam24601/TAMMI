# Functions


## Annual Adjustment

This function makes updates to the assets in the `assets` table after the actions for `current_year` have been performed. This is NOT run before the `current_year` is `start_year`. 

### Inputs

- `assets` table
- `asset_types` table
- `asset_actions` table
- `performed_actions`: The subset of `asset_details` that is assets that are going to be performed in `current_year`
- `current_year`: The current year as an integer value

### Ouput

The `assets` table

### Requirements

1. The number of rows of the `assets` table cannot change
2. The fields of the `assets` table cannot change
3. The `year_built` field must be less than or equal to `current_year`
4. The `assets` table must still pass the requirements set out in docs/input_tables.md, except for `year_built` may be greater than `start_year` so long as it is less than or equal to `current_year`.

### Default

By default, this the `replace_assets` function. This returns the `assets` table with the `year_built` column replaced for every asset with an action in `performed_actions` where `replacement_flag` is 1.


## Cost Adjustment

This function updates the cost of an action. Typically, this involves making adjustments to the `cost` field from the `asset_actions` input table to take into account things like inflation or agency soft costs. In the traditional model, this is completed before the necessary actions are prioritized.

### Inputs

- `asset_details` table
- `current_year`: The current year as an integer value
- `start_year`: The current year as an integer value

### Outputs

- `asset_details` table

### Requirements

1. The number of rows of the `asset_details` table cannot change
2. The fields of the `asset_details` table cannot change
3. The values of fields other than `cost` cannot be change
4. The `cost` field must still be integer-valued

### Defaults

By default this is the `inflation` function. This updates the `cost` column  to reflect the inflation that is expected to occur between `current_year` and `start_year`. Inflation is calculated as occuring at `inflation_rate` starting at `start_year` and compounding annually. The results are rounded to two decimal places. This has the optional input parameter of `inflation_rate`. By default `inflation_rate` is 0.3.


## Necessary Actions


## Priorities

This occurs after the cost adjustment function has been applied.