# Input Tables


## assets

Table that contains 1 row for every asset. An asset is a single individual object, like bus #24000.

| Field | Code | Description |
| ---- | ---- | ---- |
| asset_it | PK | |
| asset_type_id | FK | Keys into asset_type_id in asset_types table |
| year_built | |  Year the asset was created. This is used to calculate the age of the asset. Cannot be greater than or equal to start_year. Must be an integer value. |


## asset_types

Table that contains 1 row for each type of asset. An asset type is a set of objects that all share the same replacement and rehab actions. For example, all 40 ft. buses would be expected to have the same rehab and replacement schedules.

| Field | Code | Description |
| ---- | ---- | ---- |
| asset_type_id | PK | |
| useful_life | | The age in years that the asset must be replacement. Must be an integer value |
| replacement_cost | | The cost to replace the asset in US dollars. Must be an integer value. |