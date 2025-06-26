import os
import re
import requests
import sqlite3
from bs4 import BeautifulSoup
from urllib.parse import urljoin

# === Setup database path ===
script_dir = os.path.dirname(os.path.abspath(__file__))
db_file = os.path.join(script_dir, "device_recalls.db")

# === Scrape CDPH webpage ===
url = "https://www.cdph.ca.gov/Programs/CEH/DFDCS/Pages/FDBPrograms/DeviceRecalls.aspx"
headers = {"User-Agent": "Mozilla/5.0"}
response = requests.get(url, headers=headers)
soup = BeautifulSoup(response.text, "html.parser")

# === Connect to SQLite and create table ===
conn = sqlite3.connect(db_file)
cursor = conn.cursor()

# Drop table to fully reset it (requires manual deletion of db to fully reset structure too)
cursor.execute("DROP TABLE IF EXISTS recalls")
cursor.execute("""
    CREATE TABLE IF NOT EXISTS recalls (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recall_name TEXT,
        recall_url TEXT,
        month TEXT,
        year TEXT,
        item TEXT
    )
""")

# === Extract recalls with month/year/item ===
recalls = []
current_month = None
current_year = None

for tag in soup.find_all(["h2", "a"]):
    if tag.name == "h2":
        heading = tag.get_text(separator=" ", strip=True)
        heading = re.sub(r"[\u200B\u00A0]", " ", heading)
        heading = re.sub(r"\s+", " ", heading).strip()
        parts = heading.split()
        if len(parts) == 2 and parts[0].isalpha() and parts[1].isdigit():
            current_month, current_year = parts[0], parts[1]

    elif tag.name == "a" and "Recall" in tag.text and tag.get("href", "").endswith(".pdf"):
        recall_name = tag.get_text(strip=True)
        recall_name = re.sub(r"[\u200B\u00A0]", " ", recall_name)
        recall_name = re.sub(r"\s+", " ", recall_name).strip()

        # Extract item name (remove "FDA Recall:" and anything after "(PDF"
        item = re.sub(r"^FDA Recall:\s*", "", recall_name)
        item = re.sub(r"\(PDF.*", "", item).strip()
        item = re.sub(r"\s+", " ", item)

        recall_url = urljoin(url, tag["href"])
        recalls.append((recall_name, recall_url, current_month, current_year, item))


# === Insert into DB ===
cursor.executemany("""
    INSERT INTO recalls (recall_name, recall_url, month, year, item)
    VALUES (?, ?, ?, ?, ?)
""", recalls)

conn.commit()
conn.close()

print(f"✅ Scraping complete. {len(recalls)} recalls saved to {db_file}")
