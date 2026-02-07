#!/usr/bin/env python3
"""Extract Dham data from the full dham page with page_size=300"""
import json
from bs4 import BeautifulSoup

print("Extracting Dham data from dham_full.html...")
with open("../dham_full.html", "r", encoding="utf-8") as f:
    html = f.read()

soup = BeautifulSoup(html, "html.parser")
script = soup.find("script", id="__NEXT_DATA__")

if script:
    data = json.loads(script.string)
    articles = data["props"]["pageProps"].get("articles", [])
    print(f"Found {len(articles)} Dham items in JSON.")
    
    formatted_dhams = []
    for item in articles:
        formatted_dhams.append({
            "title": item.get("nameHindi", item.get("name", "")),
            "hindi_text": item.get("infoHindi", item.get("info", "")),
            "english_translation": "",  # Would need English scraping
            "description": f"https://www.brajrasik.org/hi/dham/{item.get('url', '')}",
            "tags": ["Braj Rasik", "Dham", "Holy Place", "84 Kos"],
            "author": "BrajRasik.org",
            "category": "dham_location",
            "metadata": {
                "slug": item.get("url", ""),
                "latitude": item.get("social", {}).get("latitude"),
                "longitude": item.get("social", {}).get("longitude"),
                "views": item.get("social", {}).get("views", 0)
            }
        })
    
    output_file = "/Users/mr.bajrangi/Code/Company/Projects/VrindaVaani/admin/dhams_complete.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(formatted_dhams, f, indent=2, ensure_ascii=False)
    
    print(f"Saved {len(formatted_dhams)} Dham locations to: {output_file}")
    
    # Show a sample
    if formatted_dhams:
        print("\nSample Dham entry:")
        print(f"Title: {formatted_dhams[0]['title']}")
        print(f"Description length: {len(formatted_dhams[0]['hindi_text'])} chars")
else:
    print("No __NEXT_DATA__ found!")
