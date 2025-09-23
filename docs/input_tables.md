# Input Tables


## assets

This table contains 1 row for every asset. An asset is a single individual object, like bus #24000.

| Field | Code | Description |
| ---- | ---- | ---- |
| `asset_it` | PK | |
| `asset_type_id` | FK | Keys into `asset_type_id` in `asset_types` table |
| `year_built` | |  Year the asset was created. This is used to calculate the age of the asset. Cannot be greater than or equal to `start_year`. Must be an integer value and non-negative. |
| `quantity` | | Number of items in the asset by unit the asset actions are measured in. For most cases this is 1, but for non-discrete assets, such as sections of rail, thiss allows cost to be scaled by size. This must be non-negative. |


## asset_types

This table contains 1 row for each type of asset. An asset type is a set of objects that all share the same replacement and rehab actions. For example, all 40 ft. buses would be expected to have the same rehab and replacement schedules.

| Field | Code | Description |
| ---- | ---- | ---- |
| `asset_type_id` | PK | |


## asset_actions

This table contains 1 row for every action. An action is a capital cost associated with an asset type, such as rehabilitation or replacement.

| Field | Code | Description |
| ---- | ---- | ---- |
| `action_id` | PK | |
| `asset_type_id` | FK | The asset_type that this action applies to. Actions can only apply to a single asset_type. This keys into `asset_type_id` in the `asset_types` table. |
| `cost` | | The cost of the action. This must be integer-valued and non-negative. If computations in dollars and cents is desired just complete the computations in cents. Using floats will cause issues with float arithmetic. |
| `replacement_flag` | | 1 if the action is a replacement; 0 otherwise. Replacements differ from other actions in that replacements update the year_built field of the asset. Once an asset is replaced, it can receive non-replacement actions that it has previously received again. |

The following field is only reuqired when using the default neccesary actions function of `actions_by_age`:

| Field | Code | Description |
| ---- | ---- | ---- |
| `age_trigger` | | Age at which, ideally, the action should be performed. The action may be scheduled after the asset reaches the age trigger in cases where there is limited budget. This must be integer-valued and non-negative. |


## asset_details

The `asset_details` table is not an input table, but rather one created by models. It is often one of the inputs for the user-supplied functions discussed in docs/functions.md. `asset_details` is created by the following R code:

```
    asset_details <- assets %>% 
      left_join(asset_types, by = "asset_type_id") %>% 
      left_join(asset_actions, by = "asset_type_id", relationship = "many-to-many")
```

`asset_details` has one record for each combination of asset and an action that can be applied to that asset. Any function that references the `asset_details` table has access to any field in the `assets`, `asset_types`, and `asset_actions` tables.


## backlog_sought

This table contains 1 row for each year and the desired value for the backlog in that year

| Field | Code | Description |
| ---- | ---- | ---- |
| `year` | | The year the budget is to be allocated for. This must contain a record for every year between, and including, (`start_year` + 1) and `end_year`. `start_year` is not included because no actions are performed the first year and instead a baseline is created. This must be integer-valued and non-negative. |
| `backlog` | | The value of the backlog desired for that year. This must be integer-valued and non-negative. If computations in dollars and cents is desired just complete the computations in cents. Using floats will cause issues with float arithmetic. |


## budgets

This table contains 1 row for each budget

| Field | Code | Description |
| ---- | ---- | ---- |
| `budget_id` | FK | Keys into the `budget_id` field of the `budgets` table | 


## budget_years

This table contains 1 row for each combination of budget and year

| Field | Code | Description |
| ---- | ---- | ---- |
| `budget_id` | FK | Keys into the `budget_id` field of the `budgets` table | 
| `year` | | The year the budget is to be allocated for. This must contain a record for every year between, and including, `start_year` and `end_year`. Note that not every `budget_id` must meet this requirement, but that there must be at least record for each year. This must be integer-valued and non-negative. |
| `budget` | | The maximum amount of money that can be allocated in a given year. This must be integer-valued and non-negative. If computations in dollars and cents is desired just complete the computations in cents. Using floats will cause issues with float arithmetic.|


## budget_actions

This table contains 1 row for each budget and an action that can be funded with that budget. This table is used to determine which action each budget is eligible to pay for.

| Field | Code | Description |
| ---- | ---- | ---- |
| `action_id` | FK | Keys into the `action_id` field of the `asset_actions` table |
| `budget_id` | FK | Keys into the `budget_id` field of the `budgets` table |