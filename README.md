How to run the codes:
1. Run the Python code, soroush_malek_flex_flattening_code.py, to flatten data. The CSV file that includes all the data will be created.
2. Declare the source data in dbt.
3. Create the model and the test for the first-level data.
4. Create the model and the test for the second-level data.
5. Create the model and the test for the lowest-level data.

Here is an ERD diagram for the data: 
![Screenshot 2025-02-18 at 5 02 07 PM](https://github.com/user-attachments/assets/51229d8e-b101-447d-b3e8-f5c26a744568)
Link to where I drew it: https://app.diagrams.net/#G1s5bcLiJoI82z2locSu7TLlna_wWPV9fd#%7B%22pageId%22%3A%22YCvazuojg-0Ej7p4dK_Y%22%7D 

From now, this document explains my approach to the problem, the assumptions I made, the issues I found in the data, and what I would do if I had more time.

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

By using dbt, I tried to add unique_key on each of those models. The main goal of that is to help better testing the data, ensure there is no dupes and also using those keys to do the join rater than using the name and categories, etc. 

## Assumptions I Made

I assumed that the top-level categories, Assets, Liabilities, and Equity, would always be present in the dataset, as they are in the JSON file. These are fundamental financial categories, so I considered them as a given in every balance sheet structure.

I also assumed that the data should be complete and consistent. If there were any discrepancies—such as a parent category’s total not matching the sum of its subcategories—the process should raise an error rather than silently passing incorrect data. 
For example, I noticed a discrepancy when summing the subcategories of Current Liabilities, which meant that the validation tests needed to catch and flag this issue.

I assumed that any record without sub-items was a lowest-level entry in the hierarchy. These lowest-level records should always exist for every category or subcategory, meaning that every financial grouping ultimately ties back to individual accounts. 
I also assumed that every lowest-level record should have an account_id associated with it, making it traceable back to a specific financial account. However, I noticed that some lowest-level records in the dataset were missing account_id, which raised some questions about how the data was structured.

One thing I did not consider in this implementation was how this dataset might relate to other data in a real warehouse. I focused on flattening and validating the JSON file itself but did not explore how it would integrate with other financial data sources or what a more holistic data model would look like in a production environment. If I had more information about the broader data ecosystem, I would refine the modeling approach accordingly.

I didn’t consider slowly changing dimensions (SCDs) or how to properly store this data in a warehouse using the right materialization strategies. 
I didn’t explore whether this should be a table, an incremental model, or a snapshot, as my focus was on flattening and validating the data rather than designing a long-term storage solution.

## Issues and Inconsistencies in the Data

There were a few inconsistencies in the data. The JSON file initially had formatting issues, likely due to copy-pasting. I had to fix these errors before processing to ensure the file could be properly read and flattened.

I also found a mismatch in Current Liabilities, where the sum of its subcategories did not match the reported total. This discrepancy suggests either a data entry issue or missing records, which should ideally be flagged as an error.

Another issue was that one record at the lowest level did not have an account_id, even though all lowest-level entries should have one. This seems to be an error in the dataset. 
Additionally, another record had an account ID with a very different format and structure, which also appeared inconsistent with the rest of the data.

Another issue was the lack of timestamp fields, such as created_date or modified_date. Without this information, it would be difficult to track changes over time, report on historical data, or verify when the data was last updated.
I could have added a timestamp to record when the data was ingested, but given the timeline, I decided not to. 
However, in a real-world scenario, some form of timestamping would be necessary to ensure data freshness, track changes, and provide better visibility into when each record was created or reported.

## If I had more time

If I had more time, I would improve validation checks to catch missing data and hierarchy inconsistencies earlier. 
I would also optimize the script for larger datasets, enhance dbt tests to identify more discrepancies, and integrate the process into a data warehouse like Snowflake or Redshift for better scalability.

