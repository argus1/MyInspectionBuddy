from flask import Flask, request
import requests
from openpyxl import Workbook
import os

app = Flask(__name__)

@app.route("/", methods=["GET"])
def index():
    min_date = request.args.get("min_date", "")
    max_date = request.args.get("max_date", "")

    if min_date and max_date:
        return search510k(min_date, max_date)

    return """
        <form method="get">
            <label for="min_date">Enter minimum date (YYYYMMDD):</label>
            <input type="text" id="min_date" name="min_date" placeholder="YYYMMMDD" required><br><br>

            <label for="max_date">Enter maximum date (YYYYMMDD):</label>
            <input type="text" id="max_date" name="max_date" placeholder="YYYMMMDD" required><br><br>

            <input type="submit" value="Search">
        </form>
    """

def search510k(min_date, max_date):
    try:
        query_range = f"{min_date}+TO+{max_date}"

        apikey = 'e3oka6wF312QcwuJguDeXVEN6XGyeJC94Hirijj8'
        url = f'https://api.fda.gov/device/510k.json?api_key={apikey}&search=decision_date:[{query_range}]&limit=100'

        response = requests.get(url)

        if response.status_code == 200:
            data = response.json()

            if 'results' not in data:
                return f"<p>No results found for date range <code>{min_date} to {max_date}</code>.</p><p><a href='/'>Try again</a></p>"

            # Export to Excel
            wb = Workbook()
            ws = wb.active
            header = list(data['results'][0].keys())
            ws.append(header)
            for item in data['results']:
                ws.append([str(v) for v in item.values()])

            output_dir = os.path.dirname(os.path.abspath(__file__))
            os.makedirs(output_dir, exist_ok=True)
            filename = os.path.join(output_dir, f"{min_date}TO{max_date}_output.xlsx")
            wb.save(filename)

            return f"""
                <p>Search successful for date range: <b>{min_date}to{max_date}</b></p>
                <p>Query Range <b>{query_range}</b></p>
                <p><a href="{url}" target="_blank">View JSON on FDA API</a></p>
                <p>Excel file saved at:<br><code>{filename}</code></p>
                <p><a href="/">Search again</a></p>
            """
        else:
            return f"<p>API request failed with status code {response.status_code}.</p><p><a href='/'>Try again</a></p>"

    except Exception as e:
        return f"<p>Error: {e}</p><p><a href='/'>Back</a></p>"

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=True)
