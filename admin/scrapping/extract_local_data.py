
import json
from bs4 import BeautifulSoup

def extract_dham_from_html():
    print("Extracting Dham data from HTML...")
    # File is in parent dir
    with open("../dham_list.html", "r", encoding="utf-8") as f:
        html = f.read()
    
    soup = BeautifulSoup(html, "html.parser")
    script = soup.find("script", id="__NEXT_DATA__")
    
    if script:
        try:
            data = json.loads(script.string)
            # Navigate to the articles/items
            articles = data["props"]["pageProps"].get("articles", [])
            print(f"Found {len(articles)} Dham items in JSON.")
            
            cleaned_items = []
            for item in articles:
                cleaned_items.append({
                    "title": item.get("nameHindi") or item.get("name"),
                    "english_title": item.get("name"),
                    "description": item.get("infoHindi") or item.get("info"), 
                    "english_description": item.get("info"),
                    "slug": item.get("url"),
                    "category": "Dham",
                    "source_url": f"https://www.brajrasik.org/hi/dham/{item.get('url')}"
                })
            return cleaned_items
            
        except KeyError as e:
            print(f"KeyError extracting dham: {e}")
            return []
    else:
        print("No __NEXT_DATA__ found in dham_list.html")
        return []

def extract_saints_from_file():
    print("Extracting Saints data from HTML...")
    with open("../saints_list_hi.html", "r", encoding="utf-8") as f:
        html = f.read()
    
    soup = BeautifulSoup(html, "html.parser")
    
    # Try to find standard elements
    # Based on previous scraper/browser analysis, names might be in h4 or specific classes
    # If standard layout:
    saints = []
    items = soup.find_all("h4")
    print(f"Found {len(items)} h4 elements in Saints HTML.")
    
    for h4 in items:
        a = h4.find("a")
        if a:
            name = a.get_text(strip=True)
            href = a.get("href")
            full_link = f"https://www.brajrasik.org{href}" if href.startswith("/") else href
            
            # Bio is often in the next sibling div or p
            # finding next sibling that is a div
            bio = ""
            next_node = h4.find_next_sibling("div")
            if next_node:
                bio = next_node.get_text(strip=True)
            
            saints.append({
                "title": name,
                "description": bio,
                "category": "Saint",
                "source_url": full_link
            })
            
    print(f"Extracted {len(saints)} saints from HTML.")
    return saints

if __name__ == "__main__":
    all_data = []
    
    dhams = extract_dham_from_html()
    all_data.extend(dhams)
    
    saints = extract_saints_from_file()
    all_data.extend(saints)
    
    output_file = "/Users/mr.bajrangi/Code/Company/Projects/VrindaVaani/admin/brajrasik_extra_extracted.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(all_data, f, indent=2, ensure_ascii=False)
    
    print(f"Saved {len(all_data)} items to {output_file}")
