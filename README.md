This document explains my approach to the problem, the assumptions I made, the issues I found in the data, and what I would do if I had more time.
Note: I completed this quickly and with some simple assumptions while ensuring correctness and efficiency.

## My Approach to the Problem

I started by understanding the structure of the JSON file, which contained nested financial data under Assets, Liabilities, and Equity. Since the data had multiple hierarchy levels, I wrote a Python script to recursively traverse and flatten the structure while preserving parent-child relationships.

I’ve worked a lot with deeply nested JSON files before and have found Lambda and Glue ETL very convenient and dynamic for handling this type of transformation. 
With them, we could create the data catalog dynamically and handle schema evolution more efficiently. However, for this assignment, I kept things simple and implemented the flattening purely in Python.

I also ensured that lowest-level records were properly identified and exported the final dataset as a CSV file, which could hypothetically be queried as a source table in a data warehouse. 
While I chose CSV for simplicity, Parquet or even Iceberg tables would have been better for this scenario, allowing for better storage, querying, and schema evolution. But in this case, I prioritized a straightforward implementation.

For validation, I used SQL/dbt tests to check whether subcategory sums matched their parent categories, verify hierarchy consistency, and catch any discrepancies. 
Instead of testing everything in Python, I preferred creating separate tests for different levels in dbt/SQL since, in my experience, this approach provides better visibility and flexibility rather than forcing all validations into one Python script.

Of course, my models and code are not highly optimized, but my goal was to properly define different levels and ensure that we don’t mix or mismatch grain levels.
