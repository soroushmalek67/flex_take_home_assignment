import pandas as pd
import json

# Function to recursively flatten the JSON structure
def flatten_json(data):
    flattened_data = []
    
    def recursive_flatten(items, parent_category, parent_name=None):
        for item in items:
            account_id = item.get("account_id", None)
            name = item.get("name", "")
            value = float(item.get("value", 0))

            # Assign correct Parent Name
            # if it's first level, then it should be none
            current_parent = parent_name if parent_name else parent_category

            # Check if this is the lowest-level record
            # this is useful to ensure what is the lowest level/account level records in the JSON file
            is_lowest_level = not item.get("items", [])

            flattened_data.append({
                "Category": parent_category,
                "Parent Name": current_parent,
                "Name": name,
                "Account ID": account_id,
                "Value": value,
                "Is_Lowest_Level": is_lowest_level  
            })
            
            # Recursively process sub-items
            if item.get("items"):
                recursive_flatten(item["items"], parent_category, name)

    for key, value in data.items():
        if isinstance(value, dict) and "name" in value and "value" in value:
            category_name = value["name"]
            total_value = float(value["value"])
            
            # Add the root category entry
            flattened_data.append({
                "Category": category_name,
                "Parent Name": None,
                "Name": category_name,
                "Account ID": None,
                "Value": total_value,
                "Is_Lowest_Level": False  
            })

            # Process sub-items dynamically
            if value.get("items"):
                recursive_flatten(value["items"], category_name)

    return pd.DataFrame(flattened_data)

# Load JSON from a file
with open("flex_take_home.json", "r") as file:
    json_data = json.load(file)

# Flatten the JSON dynamically with fixed hierarchy and lowest-level flag
df_flattened = flatten_json(json_data)

# Save to CSV for easier analysis
df_flattened.to_csv("flattened_balance_sheet_final.csv", index=False)

# Display preview
print(df_flattened.head())