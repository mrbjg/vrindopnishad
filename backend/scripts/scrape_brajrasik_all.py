import json
import urllib.request
import time
from pathlib import Path

BASE_API = "https://www.brajrasik.org/api"
OUT_DIR = Path(__file__).parent

def fetch_url(url, retries=3, delay=2):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(req, timeout=30) as response:
                return response.read().decode('utf-8')
        except Exception as e:
            print(f"⚠️ Attempt {attempt+1}/{retries} failed for URL: {url}. Error: {e}")
            if attempt < retries - 1:
                time.sleep(delay * (2 ** attempt))
            else:
                print(f"❌ Failed to fetch {url} after {retries} attempts.")
                return None

def scrape_paged_endpoint(endpoint_name, limit=1000):
    print(f"\n🚀 Starting scrape of paged endpoint: {endpoint_name}")
    all_data = []
    skip = 0
    
    while True:
        url = f"{BASE_API}/{endpoint_name}?limit={limit}&skip={skip}"
        print(f"  Fetching {endpoint_name} (skip={skip}, limit={limit})...")
        
        response_text = fetch_url(url)
        if not response_text:
            print(f"  🛑 Stopping due to fetch failure.")
            break
            
        try:
            response_json = json.loads(response_text)
        except json.JSONDecodeError as e:
            print(f"  🛑 JSON parse error: {e}")
            break
            
        # Paged API can return a list or dict {"data": [...], "count": ...}
        if isinstance(response_json, dict):
            batch = response_json.get('data', [])
        elif isinstance(response_json, list):
            batch = response_json
        else:
            batch = []
            
        if not batch:
            print(f"  ✅ Reached end of data.")
            break
            
        all_data.extend(batch)
        print(f"  Collected {len(batch)} items. Total: {len(all_data)}")
        
        if len(batch) < limit:
            print(f"  ✅ Reached last batch.")
            break
            
        skip += limit
        time.sleep(0.3) # Throttle politely
        
    return all_data

def scrape_list_endpoint(endpoint_name):
    print(f"\n🚀 Starting scrape of list endpoint: {endpoint_name}")
    url = f"{BASE_API}/{endpoint_name}"
    response_text = fetch_url(url)
    if not response_text:
        return None
        
    try:
        data = json.loads(response_text)
        print(f"  ✅ Successfully scraped {len(data)} items.")
        return data
    except Exception as e:
        print(f"  ❌ Error parsing list endpoint {endpoint_name}: {e}")
        return None

def main():
    print("==============================================")
    print("🌟 BRAJRASIK.ORG DEEP DIVE MASTER SCRAPER 1.0 🌟")
    print("==============================================")
    
    # 1. Paged endpoints
    paged_endpoints = {
        "articles": 1000,
        "medias": 1000
    }
    
    # 2. List endpoints
    list_endpoints = [
        "places",
        "albums",
        "tags",
        "raags",
        "subjects",
        "glossarys"
    ]
    
    report = {}
    
    # Scrape Paged
    for endpoint, limit in paged_endpoints.items():
        data = scrape_paged_endpoint(endpoint, limit)
        if data is not None:
            filename = f"{endpoint}_raw.json"
            filepath = OUT_DIR / filename
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            report[endpoint] = len(data)
            print(f"💾 Saved {len(data)} items to {filename}")
            
    # Scrape Lists
    for endpoint in list_endpoints:
        data = scrape_list_endpoint(endpoint)
        if data is not None:
            filename = f"{endpoint}_raw.json"
            filepath = OUT_DIR / filename
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            report[endpoint] = len(data)
            print(f"💾 Saved {len(data)} items to {filename}")
            
    print("\n==============================================")
    print("🎉 SCRAPING COMPLETE! SUMMARY:")
    print("==============================================")
    for ep, count in report.items():
        print(f"  🔹 {ep}: {count} records")
    print("==============================================")

if __name__ == "__main__":
    main()
