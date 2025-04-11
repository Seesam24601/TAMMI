# Output Tables


# performed_actions

This table contains one record for every replacement action necessary to maintain a state of good repair. 

| Field | Code | Description |
| ---- | ---- | ---- |
| `year` | | The year the action should occur |
| `asset_id` | FK | `asset_id` of the asset that was the target of the action. Keys into `asset_id` of the `assets` table. |
| `asset_type_id` | FK | `asset_type_id` of the asset hat was the target of the action. Keys into `asset_type_id` of the `asset_types` table. |
| `action_id` | FK | `action_id` of the action. Keys into `action_id` of the `asset_actions` table |
| `budget_id` | FK | `budget_id` of the budget that was used to fund the action. Keys into the `budget_id` of the `budgets` table. Not that this table contains one entry for every year. |
| `cost` | | The cost of the action. This is calculated by applying the `cost_adjustment` function to at year to the `cost` column in `asset_actions`. |


# backlog

This table contains one record for every year where an action for an asset was deemed necessary, but was not ultimately funded. Note that this output cannot be pulled from the unconstrained model because in that model all necessary actions are funded

| Field | Code | Description |
| ---- | ---- | ---- |
| `year` | | The year the action was deemed necessary but not funded |
| `asset_id` | FK | `asset_id` of the asset that was the target of the action. Keys into `asset_id` of the `assets` table. |
| `asset_type_id` | FK | `asset_type_id` of the asset hat was the target of the action. Keys into `asset_type_id` of the `asset_types` table. |
| `action_id` | FK | `action_id` of the action. Keys into `action_id` of the `asset_actions` table |
| `cost` | | The cost of the action. This is calculated by applying the `cost_adjustment` function to at year to the `cost` column in `asset_actions`. |