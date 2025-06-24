from flask import Flask, request
import requests
from openpyxl import Workbook
from urllib.parse import quote
import os

app = Flask(__name__)

@app.route("/", methods=["GET"])
def index():
    device_name = request.args.get("device_name", "")

    if device_name:
        return search510k(device_name)

    return """
        <form method="get">
            <label for="device_name">Enter device name:</label>
            <input type="text" id="device_name" name="device_name" required>
            <input type="submit" value="Search">
        </form>
    """

def search510k(device_name):
    apikey = 'e3oka6wF312QcwuJguDeXVEN6XGyeJC94Hirijj8'

    safe_device_name = quote(f'"{device_name}"') 

    url = f'https://api.fda.gov/device/510k.json?api_key={apikey}&search=device_name:{safe_device_name}&limit=100'

    print("Constructed URL:", url)
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()

        if 'results' not in data:
            return f"<p>No results found for device: <b>{device_name}</b></p><p><a href='/'>Try again</a></p>"

        # Export to Excel
        wb = Workbook()
        ws = wb.active
        header = list(data['results'][0].keys())
        ws.append(header)
        for item in data['results']:
            ws.append([str(v) for v in item.values()])

        output_dir = os.path.dirname(os.path.abspath(__file__))
        os.makedirs(output_dir, exist_ok=True)
        filename = os.path.join(output_dir, f"{device_name}_output.xlsx")
        wb.save(filename)

        return f"""
            <p>Search successful for device: <b>{device_name}</b></p>
            <p><a href="{url}" target="_blank">View JSON on FDA</a></p>
            <p>Excel file saved at:<br><code>{filename}</code></p>
            <p><a href="/">Search again</a></p>
        """
    else:
        return f"<p>API request failed. Status code: {response.status_code}</p><p><a href='/'>Try again</a></p>"

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=True)
