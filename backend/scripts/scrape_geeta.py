import os
import json
import urllib.request
import urllib.parse
import re
import html
import uuid
import time
from html.parser import HTMLParser

# Cache directory and Output file
CACHE_DIR = "/Users/sakhi/Code/Company/Projects/Sant-Vaani/backend/scripts/scrape_cache/geeta"
OUTPUT_FILE = "/Users/sakhi/Code/Company/Projects/Sant-Vaani/frontend/data/vrindavaani_content.json"

CHAPTER_URLS = {
    1: "https://www.bhagwatgeeta.net/2024/01/bhagwat-geeta-adhyay-1.html",
    2: "https://www.bhagwatgeeta.net/2024/01/bhagwat-geeta-adhyay-2.html",
    3: "https://www.bhagwatgeeta.net/2023/08/bhagwat-geeta-adhyay-3.html",
    4: "https://www.bhagwatgeeta.net/2023/08/bhagwat-geeta-adhyay-4.html",
    5: "https://www.bhagwatgeeta.net/2023/08/bhagwat-geeta-adhyay-5.html",
    6: "https://www.bhagwatgeeta.net/2023/09/bhagwat-geeta-adhyay-6.html",
    7: "https://www.bhagwatgeeta.net/2023/09/bhagwat-geeta-adhyay-7.html",
    8: "https://www.bhagwatgeeta.net/2023/09/bhagwat-geeta-adhyay-8.html",
    9: "https://www.bhagwatgeeta.net/2023/09/bhagwat-geeta-adhyay-9.html",
    10: "https://www.bhagwatgeeta.net/2023/09/bhagwat-geeta-adhyay-10.html",
    11: "https://www.bhagwatgeeta.net/2024/01/bhagwat-geeta-adhyay-11.html",
    12: "https://www.bhagwatgeeta.net/2024/01/bhagwat-geeta-adhyay-12.html",
    13: "https://www.bhagwatgeeta.net/2024/01/bhagwat-geeta-adhyay-13.html",
    14: "https://www.bhagwatgeeta.net/2024/01/bhagwat-geeta-adhyay-14.html",
    15: "https://www.bhagwatgeeta.net/2024/01/bhagwat-geeta-adhyay-15.html",
    16: "https://www.bhagwatgeeta.net/2024/01/bhagwat-geeta-adhyay-16.html",
    17: "https://www.bhagwatgeeta.net/2024/01/bhagwat-geeta-adhyay-17.html",
    18: "https://www.bhagwatgeeta.net/2024/01/bhagwat-geeta-adhyay-18.html"
}

class GeetaHTMLParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.in_post_body = False
        self.body_depth = 0
        self.tag_stack = []
        self.elements = []
        
    def handle_starttag(self, tag, attrs):
        attr_dict = dict(attrs)
        if attr_dict.get('id') == 'post-body' or 'post-body' in attr_dict.get('class', ''):
            self.in_post_body = True
            self.body_depth = 0
            
        if self.in_post_body:
            self.body_depth += 1
            self.tag_stack.append((tag, attr_dict))

    def handle_endtag(self, tag):
        if self.in_post_body:
            self.body_depth -= 1
            if self.tag_stack:
                self.tag_stack.pop()
            if self.body_depth == 0:
                self.in_post_body = False

    def handle_data(self, data):
        if self.in_post_body and self.tag_stack:
            clean_text = html.unescape(data).strip()
            clean_text = re.sub(r'\s+', ' ', clean_text).strip()
            if not clean_text:
                return
                
            is_red = False
            for parent_tag, parent_attrs in self.tag_stack:
                style = parent_attrs.get('style', '').lower()
                if 'color: red' in style or 'color:red' in style or 'color: #ff0000' in style or 'color:#ff0000' in style:
                    is_red = True
                    break
                if parent_attrs.get('color', '').lower() == 'red':
                    is_red = True
                    break
                if parent_attrs.get('class', '') == 'shlok':
                    is_red = True
                    break
                    
            is_speaker = False
            for parent_tag, parent_attrs in self.tag_stack:
                if parent_attrs.get('class', '') == 'uvach':
                    is_speaker = True
                    break
            if len(clean_text) < 35 and ("उवाच" in clean_text or "उवाच:" in clean_text):
                is_speaker = True
                
            is_commentary_header = clean_text.startswith("तात्पर्य") or clean_text.startswith("तात्पर्य़") or (len(clean_text) < 20 and ("तात्पर्य" in clean_text or "तात्पर्य़" in clean_text))
                
            self.elements.append({
                "text": clean_text,
                "is_red": is_red,
                "is_speaker": is_speaker,
                "is_commentary_header": is_commentary_header
            })

def parse_geeta_html(html_content, chapter_no):
    parser = GeetaHTMLParser()
    parser.feed(html_content)
    
    verses = []
    current_speaker = None
    current_sanskrit_lines = []
    current_hindi_lines = []
    in_commentary = False
    
    def save_current_verse():
        sanskrit_text = " ".join(current_sanskrit_lines).strip()
        hindi_text = " ".join(current_hindi_lines).strip()
        
        if not sanskrit_text:
            return
            
        verse_no = None
        matches = list(re.finditer(r'॥\s*([०१२३४५६७८९\d\-\s]+)\s*॥', sanskrit_text))
        if matches:
            nums = []
            digit_map = {'०':'0','१':'1','२':'2','३':'3','४':'4','५':'5','६':'6','७':'7','८':'8','९':'9'}
            for match in matches:
                num_str = match.group(1).strip()
                val = "".join(digit_map.get(c, c) for c in num_str)
                if '-' in val:
                    parts = val.split('-')
                    for p in parts:
                        try:
                            nums.append(int(p.strip()))
                        except:
                            pass
                else:
                    try:
                        nums.append(int(val.strip()))
                    except:
                        pass
            if nums:
                min_n = min(nums)
                max_n = max(nums)
                if min_n == max_n:
                    verse_no = str(min_n)
                else:
                    verse_no = f"{min_n}-{max_n}"
                
        if verse_no is None:
            if "॥" not in sanskrit_text:
                return
        
        verses.append({
            "verse_no": verse_no,
            "speaker": current_speaker,
            "sanskrit": sanskrit_text,
            "hindi": hindi_text
        })
    
    for el in parser.elements:
        text = el["text"]
        
        if el["is_speaker"]:
            save_current_verse()
            current_sanskrit_lines = []
            current_hindi_lines = []
            current_speaker = text
            in_commentary = False
            
        elif el["is_red"]:
            if in_commentary or len(current_hindi_lines) > 0:
                save_current_verse()
                current_sanskrit_lines = []
                current_hindi_lines = []
                in_commentary = False
            current_sanskrit_lines.append(text)
            
        elif el["is_commentary_header"]:
            in_commentary = True
            
        else:
            if in_commentary:
                continue
            else:
                if current_sanskrit_lines:
                    current_hindi_lines.append(text)
                    
    save_current_verse()
    return verses

def fetch_and_cache(url, ch_num):
    os.makedirs(CACHE_DIR, exist_ok=True)
    cache_path = os.path.join(CACHE_DIR, f"chapter_{ch_num}.html")
    
    if os.path.exists(cache_path):
        with open(cache_path, "r", encoding="utf-8") as f:
            return f.read()
            
    print(f"Fetching Chapter {ch_num} from {url}...")
    unquoted = urllib.parse.unquote(url)
    parts = list(urllib.parse.urlsplit(unquoted))
    parts[2] = urllib.parse.quote(parts[2], safe='/')
    req_url = urllib.parse.urlunsplit(parts)
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    req = urllib.request.Request(req_url, headers=headers)
    
    try:
        with urllib.request.urlopen(req) as response:
            html_content = response.read().decode('utf-8')
        with open(cache_path, "w", encoding="utf-8") as f:
            f.write(html_content)
        time.sleep(0.5) # respect rate limit
        return html_content
    except Exception as e:
        print(f"Error fetching Chapter {ch_num}: {e}")
        return None

def main():
    print("Starting scraping of Shrimad Bhagwat Geeta...")
    
    geeta_items = []
    for ch_num, url in sorted(CHAPTER_URLS.items()):
        html_content = fetch_and_cache(url, ch_num)
        if not html_content:
            print(f"Skipping Chapter {ch_num} due to fetch error.")
            continue
            
        parsed_verses = parse_geeta_html(html_content, ch_num)
        print(f"Chapter {ch_num}: parsed {len(parsed_verses)} verses.")
        
        for idx, pv in enumerate(parsed_verses):
            v_no = pv["verse_no"] or str(idx + 1)
            
            title = f"श्रीमद्भगवद्गीता, अध्याय {ch_num}, श्लोक {v_no} - वेदव्यास, श्रीमद्भगवद्गीता ({ch_num}.{v_no})"
            slug = f"shrimad-bhagavad-gita-adhyay-{ch_num}-shlok-{v_no}"
            
            sanskrit_full = pv["sanskrit"]
            if pv["speaker"]:
                sanskrit_full = f"{pv['speaker']}\n{pv['sanskrit']}"
                
            item_id = str(uuid.uuid4())
            
            item = {
                "id": item_id,
                "title": title,
                "sanskrit_text": sanskrit_full,
                "hindi_text": pv["hindi"],
                "english_text": "",
                "english_translation": "",
                "category": "Shloka",
                "description": "",
                "content_text": "",
                "tags": ["श्रीमद्भगवद्गीता", f"अध्याय {ch_num}"],
                "status": "published",
                "author": "वेदव्यास, श्रीमद्भगवद्गीता",
                "slug": slug
            }
            geeta_items.append(item)
            
    print(f"Scraped {len(geeta_items)} total Geeta verses.")
    
    if not geeta_items:
        print("No items scraped. Aborting database merge.")
        return
        
    # Merge into vrindavaani_content.json
    if os.path.exists(OUTPUT_FILE):
        try:
            with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)
                
            # Filter out any old Bhagwat Geeta entries
            clean_existing = []
            for item in existing_data:
                tags = item.get("tags", [])
                title = item.get("title", "")
                is_old_geeta = "श्रीमद्भगवद्गीता" in tags or "श्रीमद्भगवद्गीता" in title or "shrimad-bhagavad-gita" in item.get("slug", "")
                if not is_old_geeta:
                    clean_existing.append(item)
                    
            merged_data = clean_existing + geeta_items
            print(f"Merging: {len(clean_existing)} original items + {len(geeta_items)} new items = {len(merged_data)} total items.")
            
            with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
                json.dump(merged_data, f, ensure_ascii=False, indent=2)
                
            print("Successfully saved merged database!")
        except Exception as e:
            print(f"Failed to merge database: {e}")
    else:
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            json.dump(geeta_items, f, ensure_ascii=False, indent=2)
        print("Successfully created database file and saved Geeta items!")

if __name__ == "__main__":
    main()
