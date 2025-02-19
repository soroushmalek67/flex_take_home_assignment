SELECT 
    category,  
    name AS subcategory,
    {{ dbt_utils.generate_surrogate_key('category', 'name') }} AS unique_id
    value  
FROM {{ source('financial', 'flattened_balance_sheet_final') }}
WHERE parent_name = category
