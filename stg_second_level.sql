
SELECT 
    category,
    parent_name AS first_level_subcategory,  
    Name AS second_level_subcategory,
    {{ dbt_utils.generate_surrogate_key('category', 'parent_name', 'name') }} AS unique_id,
    value
FROM {{ source('financial', 'flattened_balance_sheet_final') }}
WHERE parent_name IN (SELECT subcategory FROM {{ ref('stg_first_level') }})  