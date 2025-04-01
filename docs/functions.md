# Functions


## Function Parameters

Some user-supplied functions may have additional parameters that users will want to change between model runs. This can be done by supplying the parameter before the function is given to the model using an anonymous function. E.g. setting

```
cost_adjustment = function(...)(inflation(inflation_rate = 0.1, ...))
```

instead of 

```
cost_adjustment = inflation
```

to set the `inflation_rate` parameter of the `inflation` function to 0.1.


## Action Priorities

This function takes the necessary actions and reorders them so that they are in the order the model should apply funding to them. This occurs after the necessary actions and cost adjustment functions have been applied.

### Inputs

- `necessary_actions` table: This is a subset of the `asset_details` table that is the result of applying both the necessary actions and cost adjustment functions
- `current_year`: The current year as an integer value

### Outputs

- `necessary_actions` table reordered

### Requirements

1. The output `necessary_actions` table must be a rearrangement of the input `necessary_actions` table

### Defaults

By default this is the `prioritize_longest_wait` function. This function has the additional requirement that `asset_details` has an `age_trigger` field. The requirements for this field are as follows:

| Field | Code | Description |
| ---- | ---- | ---- |
| `age_trigger` | | Age at which, ideally, the action should be performed. The action may be scheduled after the asset reaches the age trigger in cases where there is limited budget. This must be integer-valued. |

This function rearranges `necessary_actions` so that it is ordered by longest time the action has been necessary. This is calculated by taking `(current_year - year_built) - age_trigger`.


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

Changing this from its default may cause issues with the default `actions_by_age` function for the `necessary_actions` function type. See the section on that function for details.


## Budget Carryover

This function is used to determine how unspent money in each budget is moved between years. If `current_year` is `end_year`, then this function is not called

### Inputs

- `budges` table
- `budget_years` table
- `current_year`: current year

### Outputs

- A version of `budget_years` where the only changes are to the `budget` field of the next yerar

### Requirements

1. Only the `budget` field of the next year is changed
3. All values of the `budget` field should still numeric values

### Default

By default this is the `carryover_all` function. This carryovers all unused budget from the current year to the next. 


## Budget Priorities

This function choose which budget to use to pay for an action, if there are multiple possible options. Note that this function is not called when there are no possible options.

### Inputs

- `possible_budgets`: a tibble that is formed by inner joining `budget_actions` and `budget_years` for the current year 
    and left joining `budgets` to a row of the `asset_details` table; this table contains 1 record for each budget; the information about the assets from `asset_details` is the same in every row

### Outputs

- A 1 row subset of the input `possible_budgets` table

### Requirements

1. The output must be a tibble with a single row
2. That output must be a subset of the input `possible_budgets` table

### Defaults

By default this is the `prioritize_first` function. This simply returns the first record in the input `possible_budgets` table without any reordering.


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

For more information about changing the `inflation_rate` see the section on Function Parameters above.


## Necessary Actions

This function takes every possible combination of asset and action (where both the asset and action have the same type) and returns the subset that are necessary in the `current_year`.

### Inputs

- `asset_details` table
- `previous_actions`: All actions that have been allocated in previous years. Must meet the same criteria as the `performed_actions` table type. This is so that a function of this type could know the last time an action was performed for a specific asset
- `current_year`: The current year as an integer value

### Outputs

- Subset of the `asset_details` table

### Requirements

1. The fields of the `asset_details` table cannot change
2. The output `asset_details` table must be a susbet of the input `asset_details` table with none of the values changed

### Defaults

By default this is the `actions_by_age` function. This function has the additional requirement that `asset_details` has an `age_trigger` field. The requirements for this field are as follows:

| Field | Code | Description |
| ---- | ---- | ---- |
| `age_trigger` | | Age at which, ideally, the action should be performed. The action may be scheduled after the asset reaches the age trigger in cases where there is limited budget. This must be integer-valued. |

This function takes each action and deems it only necessary when the age `(current_year  - year_built)` of the asset is greater than `age_trigger`. 

Each action can only be deemed necessary once for each asset until replacement. That means for actions where `replacement_flag` is 0, after they are performed they cannot be deemed necessary again for that same asset until `year_built` for that action changes. It is assumed that this only changes when the asset has a replacement action performed. This is handled by the `replace_assets` function that is the default for the `annual_adjustment` function type. Other functions used for this function type that do not also have this behavior may be incompatible with `actions_by_age`.

