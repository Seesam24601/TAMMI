# Output Tables


# performed_actions

This table contains one record for every replacement action necessary to maintain a state of good repair. 

| Field | Code | Description |
| ---- | ---- | ---- |
| year | | The year the replacement should be made |
| asset_id | FK | asset_id of the asset that will need replacement. Keys into asset_id of the assets table. |
| asset_type_id | FK | asset_type_id of the asset that will need replacement. Keys into asset_type_id of the asset_types table. |
| replacement_cost | | The cost of the replacement. This is calculated by applying the cost_adjustment function to at year to the replacement_cost column in asset_types. |