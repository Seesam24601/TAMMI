# Output Tables


# performed_actions

This table contains one record for every replacement action necessary to maintain a state of good repair. 

| Field | Code | Description |
| ---- | ---- | ---- |
| year | | The year the action should occur |
| asset_id | FK | asset_id of the asset that was the target of the action. Keys into asset_id of the assets table. |
| asset_type_id | FK | asset_type_id of the asset hat was the target of the action. Keys into asset_type_id of the asset_types table. |
| action_id | FK | action_id of the action. Keys into action_id of the asset_actions table |
| replacement_cost | | The cost of the action. This is calculated by applying the cost_adjustment function to at year to the cost column in asset_actions. |