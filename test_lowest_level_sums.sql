{{
    config(
        severity='error'
    )
}}

WITH second_level_totals AS (
    -- Get second-level subcategory totals
    SELECT 
        second_level_subcategory,  
        value AS reported_total
    FROM {{ ref('stg_second_level') }}  
),

account_level_totals AS (
    -- Sum up all account-level values
    SELECT 
        second_level_subcategory,  
        SUM(value) AS computed_total
    FROM {{ ref('stg_lowest_level') }}  
    GROUP BY second_level_subcategory
)

-- Return only mismatched totals (test fails if discrepancies exist)
SELECT 
    s.second_level_subcategory,
    s.reported_total,
    a.computed_total
FROM second_level_totals s
INNER JOIN account_level_totals a ON s.second_level_subcategory = a.second_level_subcategory
WHERE s.reported_total != a.computed_total