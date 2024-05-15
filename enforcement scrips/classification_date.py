# this script searches the enforcement database by classification date
# this script outputs a json file
import requests
import json

apikey = 'e3oka6wF312QcwuJguDeXVEN6XGyeJC94Hirijj8'

# Ask user for minimum date
min_date = input("Enter the minimum date (MM-DD-YYYY): ")
# Ask user for maximum date
max_date = input("Enter the maximum date (MM-DD-YYYY): ")

# Format date range for URL
date_range = f"{min_date}+TO+{max_date}"
# Clean date range for filename
clean_date_range = ''.join(c if c.isalnum() else '_' for c in date_range)

# Build the URL with user input
url = f'https://api.fda.gov/device/enforcement.json?api_key={apikey}&search=center_classification_date:{date_range}&limit=100'

# Print the constructed URL
print("Constructed URL:", url)

# Send request
response = requests.get(url)

# Check if request was successful
if response.status_code == 200:
    # JSON response
    data = response.json()
    # Export data to JSON file
    json_filename = f"{date_range}_output.json"
    with open(json_filename, 'w') as json_file:
        json.dump(data, json_file, indent=4)

        # Clean date range for filename, replacing slashes with underscores
        clean_date_range = date_range.replace('/', '_')
        json_filename = f"{clean_date_range}_output.json"

        print(f"Data exported to {json_filename} successfully.")
else:
    print('Failed to fetch data from the API.')

