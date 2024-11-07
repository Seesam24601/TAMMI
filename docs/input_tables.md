# Input Tables


## assets

This table contains 1 row for every asset. An asset is a single individual object, like bus #24000.

| Field | Code | Description |
| ---- | ---- | ---- |
| `asset_it` | PK | |
| `asset_type_id` | FK | Keys into `asset_type_id` in `asset_types` table |
| `year_built` | |  Year the asset was created. This is used to calculate the age of the asset. Cannot be greater than or equal to `start_year`. Must be an integer value. |


## asset_types

This table contains 1 row for each type of asset. An asset type is a set of objects that all share the same replacement and rehab actions. For example, all 40 ft. buses would be expected to have the same rehab and replacement schedules.

| Field | Code | Description |
| ---- | ---- | ---- |
| `asset_type_id` | PK | |


## asset_actions

This table contains 1 row for every action. An action is a capital cost associated with an asset type, such as rehabilitation or replacement.

| Field | Code | Description |
| ---- | ---- | ---- |
| `asset_action_id` | PK | |
| `asset_type_id` | FK | The asset_type that this action applies to. Actions can only apply to a single asset_type. This keys into `asset_type_id` in the `asset_types` table. |
| `cost` | | The cost of the action. This must be integer-valued. |
| `replacement_flag` | | 1 if the action is a replacement; 0 otherwise. Replacements differ from other actions in that replacements update the year_built field of the asset. Once an asset is replaced, it can receive non-replacement actions that it has previously received again. |

The following field is only reuqired when using the default neccesary actions function of `actions_by_age`:

| Field | Code | Description |
| ---- | ---- | ---- |
| `age_trigger` | | Age at which, ideally, the action should be performed. The action may be scheduled after the asset reaches the age trigger in cases where there is limited budget. This must be integer-valued. |


# budget

This table contains 1 row for every year.

| Field | Code | Description |
| ---- | ---- | ---- |
| `year` | PK | The year the budget is to be allocated for. This must contain a record for every year between, and including, `start_year` and `end_year`. This must be integer-valued. |
| `budget` | | The maximum amount of money that can be allocated in a given year. This must be integer-valued |