
SELECT 
    category,
    parent_name AS second_level_subcategory,  
    name AS account_name,  
    account_id,  
    value
FROM {{ source('financial', 'flattened_balance_sheet_final') }}
WHERE is_lowest_level