{{
    config(
        severity='error'
    )
}}

WITH first_level_totals AS (
    -- Get first-level subcategory totals (no SUM needed if values are unique)
    SELECT 
        subcategory AS first_level_subcategory,  
        value AS reported_total 
    FROM {{ ref('stg_first_level') }}  
),

second_level_totals AS (
    -- Sum up all second-level subcategory values
    SELECT 
        first_level_subcategory,  
        SUM(value) AS computed_total
    FROM {{ ref('stg_second_level') }}  
    GROUP BY first_level_subcategory
)

-- Return only mismatched totals (test fails if discrepancies exist)
SELECT 
    f.first_level_subcategory,
    f.reported_total,
    s.computed_total
FROM first_level_totals f
INNER JOIN second_level_totals s ON f.first_level_subcategory = s.first_level_subcategory
WHERE f.reported_total != s.computed_total
