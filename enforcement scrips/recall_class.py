# this script searches the enforcement database by recall class
# this script outputs a json file
import requests
import json

apikey = 'e3oka6wF312QcwuJguDeXVEN6XGyeJC94Hirijj8'

# Ask user for search term
search_term = input("Enter the recall class to search for ( I, II, or III) : ")

# Build the URL with user input
url = f'https://api.fda.gov/device/enforcement.json?api_key={apikey}&search=classification:{search_term}&limit=100'

# Print the constructed URL
print("Constructed URL:", url)

# Send request
response = requests.get(url)

# Check if request was successful
if response.status_code == 200:
    # JSON response
    data = response.json()
    # Export data to JSON file
    json_filename = f"{search_term}_output.json"
    with open(json_filename, 'w') as json_file:
        json.dump(data, json_file, indent=4)


    print(f"Data exported to {json_filename} successfully.")
else:
    print("Failed to fetch data from the API.")

