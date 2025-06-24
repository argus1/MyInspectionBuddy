
# this script is for the 510k database, for the applicant name search field
# this script provides a clickable url link to the json data
# this script provides a downloadable Excel file in the directory where the script is ran
#! python3

from flask import Flask, request
import requests
from openpyxl import Workbook
from urllib.parse import quote
import os

app = Flask(__name__)

@app.route("/", methods=["GET"])
def index():

    #applicant_name is the name of the company
    applicant_name = request.args.get("applicant_name", "")
    
    if applicant_name:
        return search510k(applicant_name)
    
    return """
        <form method="get">
            <label for="applicant_name">Enter applicant name:</label>
            <input type="text" id="applicant_name" name="applicant_name" required>
            <input type="submit" value="Search">
        </form>
    """

def search510k(search_term):
    
    apikey = 'e3oka6wF312QcwuJguDeXVEN6XGyeJC94Hirijj8'

    safe_search_term= quote(f'"{search_term}"') 

    url = f'https://api.fda.gov/device/510k.json?api_key={apikey}&search=applicant:{safe_search_term}&limit=100'

    print("Constructed URL:", url)
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        if 'results' not in data:
            return f"<p>No results found for <b>{search_term}</b>.</p><p><a href='/'>Try again</a></p>"

        # Export to Excel
        wb = Workbook()
        ws = wb.active
        header = list(data['results'][0].keys())
        ws.append(header)
        for item in data['results']:
            ws.append([str(v) for v in item.values()])

        output_dir = os.path.dirname(os.path.abspath(__file__))
        os.makedirs(output_dir, exist_ok=True)
        filename = os.path.join(output_dir, f"{search_term}_output.xlsx")
        wb.save(filename)

        return f"""
            <p>Search successful for: <b>{search_term}</b></p>
            <p><a href="{url}" target="_blank">View JSON on FDA</a></p>
            <p>Excel file saved as <code>{filename}</code> in current directory.</p>
            <p><a href="/">Search again</a></p>
        """
    else:
        return f"<p>API request failed. Status code: {response.status_code}</p><p><a href='/'>Try again</a></p>"

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=True)




