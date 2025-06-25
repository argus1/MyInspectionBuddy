# this script searches the enforcement database by classification date
#! python3

from flask import Flask
import requests
import csv
from openpyxl import Workbook
import os
import string

app = Flask(__name__)

@app.route("/")
def index():
    # return "search item - 510k"
    # optional - replace html date range form with html date picker form
        date_range = request.args.get("date_range", "")
    return (
        """<form action="" method="get">
                <input type="text" name="classification date MM/DD/YYYY">
                <input type="submit" value="Convert">
            </form>"""
        + date_range
    )

@app.route("/<date_range>")

def search510k():

apikey = 'e3oka6wF312QcwuJguDeXVEN6XGyeJC94Hirijj8'

# Ask user for minimum date
min_date = input("Enter the minimum date (MM/DD/YYYY): ")
# Ask user for maximum date
max_date = input("Enter the maximum date (MM/DD/YYYY): ")

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
    # Export data to CSV
    with open('output.csv', 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile)
        # Write header
        csvwriter.writerow(data['results'][0].keys())
        # Write data
        for item in data['results']:
            csvwriter.writerow(item.values())

        # Export data to Excel
        wb = Workbook()
        ws = wb.active
        header = list(data['results'][0].keys())  # Header
        ws.append(header)  # Write header
        for item in data['results']:
            values = ["".join(filter(lambda x: x in string.printable, str(v))) for v in
                      item.values()]  # Remove non-printable characters
            ws.append(values)  # Write data

        # Get the current working directory
        current_directory = os.getcwd()
        # Create the full path for the Excel file
        excel_filename = os.path.join(current_directory, f"{clean_date_range}_output.xlsx")

        wb.save(excel_filename)
        print(f"Data exported to {excel_filename} successfully.")
else:
    print('Failed to fetch data from the API.')

# Starts Flask Development Server when script is executed from command line
if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=True)
