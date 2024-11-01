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

### Default

By default, this the `replace_assets` function. This returns the `assets` table with the `year_built` column replaced for every asset with an action in `performed_actions` where `replacement_flag` is 1.


## Cost Adjustment


## Necessary Actions


## Priorities