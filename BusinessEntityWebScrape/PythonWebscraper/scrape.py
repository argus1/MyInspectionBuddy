import sqlite3
import time
import string
import argparse
import json
from playwright.sync_api import sync_playwright
from pathlib import Path

# ---- Configuration ----
DB         = 'business_entities.db'
API_URL    = 'https://bizfileonline.sos.ca.gov/api/business/search'
PAGE_SIZE  = 50           # number of results per page (max the endpoint allows) - override via --page-size
TERMS      = list(string.ascii_uppercase)  # ['A','B',…,'Z']; override via --term/--all
DELAY      = 0.5          # pause between requests (seconds) - override via --delay

def fetch_json(term, page_num, page_size):
    search_page_url = "https://bizfileonline.sos.ca.gov/search/business"
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context(
            user_agent=(
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/115.0.0.0 Safari/537.36"
            ),
            viewport={"width": 1280, "height": 800}
        )
        page = context.new_page()

        try:
            page.goto(search_page_url, timeout=60000)

            # Save HTML and print visible button-like elements for debugging
            Path("page_debug.html").write_text(page.content(), encoding='utf-8')
            print("\n🔎 Dumping all button-like elements on page:")
            for tag in page.query_selector_all("button, div, span"):
                try:
                    text = tag.inner_text().strip()
                    box = tag.bounding_box()
                    if box and (text or box["width"] > 10):
                        tag_name = tag.evaluate("e => e.tagName")
                        print(f"  → tag: {tag_name}, text: '{text}', box: {box}")
                except Exception as e:
                    continue

            page.wait_for_timeout(5000)

            # Simulate mouse movement to trigger bot protection bypass
            page.mouse.move(100, 100)
            page.mouse.move(200, 200)
            page.mouse.move(300, 100)
            page.mouse.move(400, 200)
            page.wait_for_timeout(1000)

            # Save HTML to inspect response
            Path("page_debug.html").write_text(page.content(), encoding='utf-8')

            # Wait for placeholder text in search input to appear
            page.wait_for_selector("input[placeholder*='Search by name']", timeout=15000)

            # Simulate real human typing
            search_input = page.query_selector("input[placeholder*='Search by name']")
            search_input.click()
            page.keyboard.type(term, delay=100)

            # Click the first button that's ~40px and has no inner text (likely the magnifying glass icon)
            clicked = False
            for button in page.query_selector_all("button"):
                try:
                    text = button.inner_text().strip()
                    box = button.bounding_box()
                    if text == '' and box and 35 <= box["width"] <= 45 and 35 <= box["height"] <= 45:
                        print(f"✅ Clicking likely search icon at {box}")
                        page.mouse.click(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2)
                        clicked = True
                        break
                except:
                    continue
            if not clicked:
                print("❌ No clickable search icon button matched size/text filter.")

            # Wait for the search results XHR call
            with page.expect_response(lambda r: r.url.startswith(API_URL) and r.request.method == "GET") as resp_info:
                page.wait_for_load_state("networkidle")
                page.wait_for_timeout(5000)

            response = resp_info.value
            return response.json()
        except Exception as e:
            print(f"❌ Failed to fetch term {term}: {e}")
            return {"items": [], "totalPages": 0}
        finally:
            browser.close()

# ---- Database setup ----
def init_db():
    conn = sqlite3.connect(DB)
    c = conn.cursor()
    c.execute('''
      CREATE TABLE IF NOT EXISTS entities (
        business_id        INTEGER PRIMARY KEY,
        business_name      TEXT,
        business_number    TEXT,
        filing_date        TEXT,
        status             TEXT,
        entity_type        TEXT,
        jurisdiction       TEXT,
        agent_name         TEXT
      );
    ''')
    c.execute('CREATE INDEX IF NOT EXISTS idx_name ON entities(business_name);')
    c.execute('CREATE INDEX IF NOT EXISTS idx_type ON entities(entity_type);')
    conn.commit()
    return conn

# ---- Scraping one page of one term ----
def scrape_page(conn, term, page_num):
    data = fetch_json(term, page_num, PAGE_SIZE)

    rows = []
    for item in data.get('items', []):
        rows.append((
          item['businessId'],
          item['businessName'],
          item['businessNumber'],
          item.get('filingDate', ''),
          item.get('status',''),
          item.get('entityType',''),
          item.get('jurisdiction',''),
          item.get('agentName','')
        ))

    conn.executemany('''
      INSERT OR IGNORE INTO entities
        (business_id, business_name, business_number, filing_date,
         status, entity_type, jurisdiction, agent_name)
      VALUES (?,?,?,?,?,?,?,?)
    ''', rows)
    conn.commit()

    return data.get('totalPages', 0)

# ---- Main loop: iterate terms and pages ----
def main(terms, page_size, delay):
    conn = init_db()

    for term in terms:
        print(f"\n=== Scraping term '{term}' ===")
        page = 1
        total = 1

        while page <= total:
            print(f"  • Page {page}/{total if total>1 else '?'}…", end='', flush=True)
            total = scrape_page(conn, term, page) or total
            print(" done.")
            page += 1
            time.sleep(delay)

    conn.close()
    print("\nAll done! Database saved to", DB)

# parser = argparse.ArgumentParser(description="Scrape CA SOS business entities")
# group = parser.add_mutually_exclusive_group(required=True)
# group.add_argument('--all', action='store_true', help='Scrape all A–Z prefixes')
# group.add_argument('--term', type=str, metavar='X', help='Scrape only the given prefix (e.g. \"A\")')
# parser.add_argument('--page-size', type=int, default=PAGE_SIZE, help='Results per page')
# parser.add_argument('--delay', type=float, default=DELAY, help='Delay between requests (seconds)')
# args = parser.parse_args()
#
# if args.all:
#     terms = TERMS
# else:
#     terms = [args.term.upper()]
#
# main(terms, args.page_size, args.delay)

# To run after updating the script:
# pip install playwright
# playwright install
# python scrape.py --term A
# sqlite3 business_entities.db "SELECT COUNT(*) FROM entities;"


import math
import requests

def scrape_businesses_api(search_term, max_pages=3, page_size=500):
    url = "https://bizfileonline.sos.ca.gov/api/business/search"

    headers = {
        "Content-Type": "application/json",
        "Origin": "https://bizfileonline.sos.ca.gov",
        "Referer": "https://bizfileonline.sos.ca.gov/search/business",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36"
    }

    for page in range(max_pages):
        offset = page * page_size
        payload = {
            "SEARCH_VALUE": search_term,
            "SEARCH_FILTER_TYPE_ID": "0",
            "SEARCH_TYPE_ID": "1",
            "FILING_TYPE_ID": "",
            "AUDITOR_NAME": "",
            "BANKRUPTCY_YN": False,
            "COMPENSATION_FROM": "",
            "COMPENSATION_TO": "",
            "CORPORATION_BANKRUPTCY_YN": False,
            "CORPORATION_LEGAL_PROCEEDINGS_YN": False,
            "FILING_DATE": {"start": None, "end": None},
            "FRAUD_YN": False,
            "LOANS_YN": False,
            "NUMBER_OF_FEMALE_DIRECTORS": "99",
            "NUMBER_OF_UNDERREPRESENTED_DIRECTORS": "99",
            "OFFICER_OBJECT": {
                "FIRST_NAME": "",
                "MIDDLE_NAME": "",
                "LAST_NAME": ""
            },
            "OPTIONS_YN": False,
            "SHARES_YN": False,
            "STATUS_ID": "",
            "STARTS_AT": offset,
            "MAX_ENTITY_COUNT": page_size
        }

        print(f"\n🔍 Requesting page {page + 1} (offset {offset})...")
        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()
        data = response.json()

        results = data.get("BusinessSearchResults", [])
        if not results:
            print("No more results.")
            break

        for item in results:
            name = item.get("EntityName", "N/A")
            etype = item.get("EntityType", "N/A")
            status = item.get("StatusDescription", "N/A")
            print(f"• {name} — {etype} — {status}")

# ---- API scraping test call ----
if __name__ == '__main__':
    scrape_businesses_api("Tesla", max_pages=2)
    if len(sys.argv) != 2:
        print("Usage: python import_data.py <path_to_json_file>")
        sys.exit(1) 
