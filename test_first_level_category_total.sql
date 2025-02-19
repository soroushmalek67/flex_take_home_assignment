{{
    config(
        severity='error'
    )
}}

WITH category_totals AS (
    -- Fetch all top-level categories dynamically
    SELECT 
        name AS category,  
        value AS reported_total
    FROM {{ source('financial', 'flattened_balance_sheet_final') }}
    WHERE parent_name IS NULL
)
,
sub_category_totals AS (
    -- Sum over all first-level subcategories for each main category
    SELECT 
        category,  
        SUM(value) AS computed_total
    FROM {{ ref('stg_first_level') }}  
    GROUP BY category
)
-- Return only mismatched totals (fail test if discrepancies exist)
SELECT 
    c.category,
    c.reported_total,
    s.computed_total
FROM category_totals c
LEFT JOIN sub_category_totals s ON c.category = s.category
WHERE c.reported_total != s.computed_total 