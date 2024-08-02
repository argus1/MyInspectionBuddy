import pandas as pd
import os

# Get the current working directory
directory = os.getcwd()

# Initialize an empty DataFrame to store the combined data
combined_df = pd.DataFrame()

# Iterate over each file in the directory
for filename in os.listdir(directory):
    if filename.endswith(".csv"):
        file_path = os.path.join(directory, filename)
        # Read the data from the current file
        df = pd.read_csv(file_path)
        # Concatenate the data to the combined DataFrame
        combined_df = pd.concat([combined_df, df], ignore_index=True)

# Save the combined data to a new .csv file
combined_df.to_csv("combined_data.csv", index=False)

# Print a success message
print("Combined data saved to combined_data.csv")