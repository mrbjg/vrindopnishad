import json
import urllib.request
import urllib.parse
import re
import time
from datetime import datetime, timezone
from pathlib import Path

def clean_html(raw_html):
    if not raw_html: return ""
    # Preserve line breaks for verses
    text = raw_html.replace('<br>', '\n').replace('<br/>', '\n').replace('</div>', '\n').replace('</p>', '\n')
    cleanr = re.compile('<script.*?>.*?</script>|<style.*?>.*?</style>', re.DOTALL)
    text = re.sub(cleanr, '', text)
    cleanr = re.compile('<.*?>')
    text = re.sub(cleanr, '', text)
    # Fix HTML entities
    text = text.replace('&nbsp;', ' ').replace('&amp;', '&').replace('&quot;', '"')
    return text.strip()

def fetch_json(url):
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=30) as response:
            return json.loads(response.read().decode('utf-8'))
    except Exception as e:
        print(f"Error fetching API {url}: {e}")
        return None

def main():
    BASE_API = "https://www.brajrasik.org/api/articles"
    LIMIT = 1000
    skip = 0
    all_results = []
    
    output_path = Path(__file__).parent / "scraped_data.json"
    
    print(f"--- Braj Rasik LANGUAGE-AWARE Scraper 5.2 ---")
    
    while True:
        url = f"{BASE_API}?limit={LIMIT}&skip={skip}"
        print(f"Fetching batch: skip={skip}...")
        
        response_data = fetch_json(url)
        if not response_data or 'data' not in response_data:
            break

        articles = response_data['data']
        if not articles:
            break
            
        for art in articles:
            translations = art.get('translation', [])
            root_lang = art.get('lang', 'hindi')
            
            # API Mapping:
            # Index 0 is English
            # Index 1 is Native (Hindi/Sanskrit/Braj)
            eng_obj = translations[0] if len(translations) > 0 else {}
            native_obj = translations[1] if len(translations) > 1 else (translations[0] if len(translations) == 1 else {})
            
            title = native_obj.get('title') or eng_obj.get('title') or art.get('url')
            native_content = clean_html(native_obj.get('detail', ''))
            eng_content = clean_html(eng_obj.get('detail', ''))
            
            # Separate Sanskrit if it looks like a verse
            sanskrit_text = ""
            hindi_text = native_content
            
            # If the article is explicitly sanskrit, or contains verses
            if root_lang == "sanskrit" or "॥" in native_content:
                parts = native_content.split('\n\n', 1)
                if len(parts) > 1:
                    sanskrit_text = parts[0]
                    hindi_text = parts[1]
                else:
                    sanskrit_text = native_content
            
            category = "general"
            url_path = art.get('url', '')
            if 'sankirtan' in url_path: category = "sankirtan"
            elif 'saint' in url_path: category = "saint"
            elif 'dham' in url_path: category = "dham"
            elif 'literature' in url_path: category = "literature"
            
            # Robust Tag Parsing
            tags_raw = art.get('tags', [])
            tags_clean = [t.get('name', '') if isinstance(t, dict) else t for t in tags_raw]
            
            if title and native_content:
                all_results.append({
                    "title": title,
                    "sanskrit_text": sanskrit_text,
                    "hindi_text": hindi_text,
                    "english_translation": eng_content if eng_content != native_content else "",
                    "category": category,
                    "tags": tags_clean,
                    "author": art.get('author', {}).get('name', 'Braj Rasik Heritage') if isinstance(art.get('author'), dict) else 'Braj Rasik Heritage',
                    "status": "published",
                    "description": clean_html(art.get('description', ''))[:250],
                    "image_url": art.get('image'),
                    "audio_url": art.get('audio'),
                    "slug": art.get('url')
                })

        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(all_results, f, ensure_ascii=False, indent=2)
            
        if len(articles) < LIMIT:
            break
            
        skip += LIMIT
        time.sleep(0.3)

    print(f"🎉 SUCCESS: {len(all_results)} records correctly mapped and saved.")

if __name__ == "__main__":
    main()
