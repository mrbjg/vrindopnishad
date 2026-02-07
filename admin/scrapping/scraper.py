import requests
from bs4 import BeautifulSoup
import json
import time
import os
import re

BASE_URL = "https://www.brajrasik.org"
SUPABASE_URL = "https://tilimltxgeucefxzerqi.supabase.co"
SUPABASE_KEY = "sb_publishable_0YiM-Q8itRORUDdToracaQ_vzcrjUlC"
REST_URL = f"{SUPABASE_URL}/rest/v1/content"

def get_article_urls_from_sitemap(lang='hi'):
    """
    Parses sitemap.xml to get all article URLs.
    """
    sitemap_url = "https://www.brajrasik.org/sitemap.xml"
    print(f"Fetching sitemap from {sitemap_url}...")
    try:
        response = requests.get(sitemap_url)
        content = response.text
        # More robust extraction
        urls = []
        for loc in re.findall(r'<loc>(.*?)</loc>', content):
            if '/articles/' in loc:
                urls.append(loc)
        
        # Localize to Hindi if requested
        if lang == 'hi':
            hindi_urls = []
            for url in urls:
                if "/hi/articles/" in url:
                    hindi_urls.append(url)
                else:
                    h_url = url.replace("/articles/", "/hi/articles/")
                    hindi_urls.append(h_url)
            urls = list(set(hindi_urls)) # Unique
            
        print(f"Found {len(urls)} unique Hindi articles in sitemap.")
        return urls
    except Exception as e:
        print(f"Error fetching sitemap: {e}")
        return []

def insert_to_supabase(data_batch):
    """
    Inserts a batch of articles into Supabase via REST API.
    """
    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal"
    }
    try:
        response = requests.post(REST_URL, headers=headers, json=data_batch)
        if response.status_code in [201, 204]:
            print(f"Successfully inserted {len(data_batch)} items.")
            return True
        else:
            print(f"Failed to insert: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        print(f"Insertion error: {e}")
        return False

def scrape_article(url, lang='hi'):
    """
    Scrapes a single article page and extracts metadata from meta tags or HTML.
    """
    try:
        response = requests.get(url)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        data = {
            "title": "",
            "category": "General",
            "sanskrit_text": None,
            "hindi_text": None,
            "english_text": None,
            "english_translation": None,
            "description": f"Scraped from BrajRasik ({'Hindi' if lang == 'hi' else 'English'})",
            "author": "",
            "status": "published",
            "content_text": "",
            "tags": ["Braj Rasik", "Mass Import"],
            "image_urls": [],
            "video_urls": [],
            "media_links": []
        }
        
        # 1. Title - meta property="og:title"
        og_title = soup.find('meta', property='og:title')
        if og_title:
            data["title"] = og_title.get('content', '').split('-')[0].strip()
        else:
            title_tag = soup.find('title')
            if title_tag:
                data["title"] = title_tag.get_text(strip=True).split('-')[0].strip()
            
        # 2. Main Content - meta name="description"
        meta_desc = soup.find('meta', attrs={"name": "description"})
        if meta_desc:
            desc_content = meta_desc.get('content', '')
            # Clean HTML from description if present
            desc_soup = BeautifulSoup(desc_content, 'html.parser')
            clean_text = desc_soup.get_text(separator="\n", strip=True)
            data["content_text"] = clean_text
            
            # Extract Verse (strong)
            verse_tag = desc_soup.find('strong')
            if verse_tag:
                data["sanskrit_text"] = verse_tag.get_text(strip=True)
            
            # Extract Author (em)
            author_tag = desc_soup.find('em')
            if author_tag:
                author_text = author_tag.get_text(strip=True).replace('-', '').strip()
                data["author"] = author_text

            # Meaning
            meaning = clean_text
            if data["author"] and data["author"] in clean_text:
                meaning = clean_text.split(data["author"], 1)[1].strip() if len(clean_text.split(data["author"], 1)) > 1 else clean_text
            elif data["sanskrit_text"] and data["sanskrit_text"] in clean_text:
                meaning = clean_text.split(data["sanskrit_text"], 1)[1].strip() if len(clean_text.split(data["sanskrit_text"], 1)) > 1 else clean_text
            
            if lang == 'hi':
                data["hindi_text"] = meaning
            else:
                data["english_translation"] = meaning

        # 3. Category Mapping
        if "Biography" in data["title"] or "जीवनी" in data["title"]:
            data["category"] = "Katha"
        elif data.get("sanskrit_text"):
            data["category"] = "Shloka"

        data["source_url"] = url
        data["description"] = url
        
        # 4. Filter for empty data
        if not data["title"]:
            print(f"Skipping {url} because title is missing.")
            return None

        return data
    except Exception as e:
        print(f"Error scraping {url}: {e}")
        return None

def scrape_dual_article(hindi_url):
    """
    Scrapes both Hindi and English versions of an article and merges them.
    """
    print(f"  Fetching Hindi: {hindi_url}")
    hindi_data = scrape_article(hindi_url, lang='hi')
    if not hindi_data:
        return None
        
    english_url = hindi_url.replace("/hi/articles/", "/articles/")
    print(f"  Fetching English: {english_url}")
    english_data = scrape_article(english_url, lang='en')
    
    if english_data:
        print(f"    Success: Found English translation.")
        # Merge English translation into Hindi data
        hindi_data["english_translation"] = english_data["english_translation"]
        # If author was missing in Hindi but found in English, use it
        if not hindi_data.get("author") and english_data.get("author"):
            hindi_data["author"] = english_data["author"]
    else:
        print(f"    Warning: No English translation found for {english_url}.")
            
    return hindi_data

import sys

def main(lang='hi', direct_insert=True, limit=None):
    # Build list of URLs to scrape
    all_urls = get_article_urls_from_sitemap(lang=lang)
    
    if limit:
        all_urls = all_urls[:limit]
    
    print(f"Starting scrape of {len(all_urls)} {lang} articles...")
    
    # Updated output path to reflect current structure
    output_file = "/Users/mr.bajrangi/Code/Company/Projects/VrindaVaani/admin/brajrasik_dual_full.json"
    scraped_data_total = []
    current_batch = []
    batch_size = 20
    
    for i, url in enumerate(all_urls):
        print(f"[{i+1}/{len(all_urls)}] dual-scraping {url}...")
        article_data = scrape_dual_article(url)
        if article_data:
            current_batch.append(article_data)
            scraped_data_total.append(article_data)
        
        # Action based on mode
        if direct_insert:
            if len(current_batch) >= batch_size:
                insert_to_supabase(current_batch)
                current_batch = [] # Clear batch
        else:
            # Print periodic progress
            if len(scraped_data_total) % batch_size == 0 and scraped_data_total:
                print(f"Progress: {len(scraped_data_total)} items scraped so far.")
            
    # Final cleanup
    if direct_insert and current_batch:
        insert_to_supabase(current_batch)
    
    if not direct_insert:
        print(f"Scrape complete. Saving {len(scraped_data_total)} items to {output_file}...")
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(scraped_data_total, f, indent=2, ensure_ascii=False)
            f.flush()
            os.fsync(f.fileno())
        print(f"Finished! Total data saved to {output_file}")

if __name__ == "__main__":
    limit = None
    if "--limit" in sys.argv:
        idx = sys.argv.index("--limit")
        if len(sys.argv) > idx + 1:
            limit = int(sys.argv[idx+1])
            
    main(lang='hi', direct_insert=False, limit=limit)
