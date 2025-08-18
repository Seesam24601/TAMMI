# Models


## Traditional

This model takes a given budget and returns the modeled actions and backlog in future years given that budget

### Parameters

| Parameter | Description |
| --- | --- |
| `start_year` | Year to start the model. This year is used as the current status and changes are made starting in `start_year` + 1. This must be integer-valued |
| `end_year` | Last year to run the model. This must be integer-valued and must be greater than or equal to `start_year` |
| `skip_large` | A boolean value. If `skip_large` is true, then in the case where skipping an expensive action in the prioritized list of necessary actions reveals a cheaper action that is still within budget, the algorithm will choose this approach. Be careful using this with some implementations of the `budget_carryover` user-supplied function. False by default |

### Input Tables

See `input_tables.md` for details

- `assets`
- `asset_types`
- `asset_actions`
- `budgets`
- `budget_years`
- `budget_actions`

### User-Supplied Functions

See `functions.md` for detials

- `action_priorities`
- `annual_adjustment`
- `budget_carryover`
- `budget_priorities`
- `cost_adjustment`
- `necessary_actions`

### Output Tables

See `output_tables.md` for detials

- `performed_actions`
- `backlog`


## Unconstrained

This model looks at what actions would be taken in a world with no budget. This will run faster than running the traditional model with an extremely large budget as is done in TERM Lite

### Parameters

| Parameter | Description |
| --- | --- |
| `start_year` | Year to start the model. This year is used as the current status and changes are made starting in `start_year` + 1. This must be integer-valued |
| `end_year` | Last year to run the model. This must be integer-valued and must be greater than or equal to `start_year` | 

### Input Tables

See `input_tables.md` for details

- `assets`
- `asset_types`
- `asset_actions`

### User-Supplied Functions

See `functions.md` for detials

- `annual_adjustment`
- `cost_adjustment`
- `necessary_actions`

### Output Tables

See `output_tables.md` for detials

- `performed_actions`


## Backlog Seek

This models shows the required actions to meet a certain backlog (either as raw dollars or a proportion of the current backlog) in future years

### Parameters

| Parameter | Description |
| --- | --- |
| `start_year` | Year to start the model. This year is used as the current status and changes are made starting in `start_year` + 1. This must be integer-valued |
| `end_year` | Last year to run the model. This must be integer-valued and must be greater than or equal to `start_year` |
| `proportion` |  Boolean value. If true then expect values between 0 and 1 and consider them as the proportion of the backlog in the starting year that is desired in that year. False by default |

### Input Tables

See `input_tables.md` for details

- `assets`
- `asset_types`
- `asset_actions`
- `backlog_sought`

### User-Supplied Functions

See `functions.md` for detials

- `action_priorities`
- `annual_adjustment`
- `cost_adjustment`
- `necessary_actions`

### Output Tables

See `output_tables.md` for detials

- `performed_actions`
- `backlog`