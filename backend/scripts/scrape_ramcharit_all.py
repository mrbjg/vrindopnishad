import os
import re
import json
import uuid
import time
import urllib.request
import urllib.parse
import html
from concurrent.futures import ThreadPoolExecutor, as_completed
import xml.etree.ElementTree as ET

CACHE_DIR = os.path.join(os.path.dirname(__file__), "scrape_cache")
OUTPUT_FILE = os.path.join(os.path.dirname(__file__), "../../frontend/data/vrindavaani_content.json")

os.makedirs(CACHE_DIR, exist_ok=True)

# Hindi stop words for identifying Hindi translations
HINDI_WORDS = {
    'ने', 'को', 'से', 'का', 'की', 'के', 'है', 'हैं', 'था', 'थी', 'थे', 'और', 'हो', 'कर', 'पर', 'करके', 'कहा', 'पूषा', 
    'पूछा', 'बोले', 'किया', 'दिया', 'लिया', 'हुआ', 'हुए', 'हुई', 'गया', 'गए', 'गई', 'अपने', 'अपनी', 'वही', 'वहाँ', 
    'यहाँ', 'इस', 'उस', 'सूतजी', 'विदुरजी', 'शुकदेवजी', 'परीक्षित', 'मैत्रेयजी', 'कहते', 'करते', 'करेंगे', 'होगा', 
    'होती', 'जाता', 'जाती', 'जाते'
}

def clean_text(text):
    if not text:
        return ""
    text = html.unescape(text)
    text = re.sub(r'[ \t\r\f]+', ' ', text)
    lines = [line.strip() for line in text.split('\n')]
    text = '\n'.join(lines)
    text = urllib.parse.unquote(text)
    return text.strip()

def is_hindi_text(text):
    words = {w for w in re.split(r'[\s।॥,.:;!?()（）\'\"\[\]\-–—+|\\/]+', text) if w}
    return bool(words.intersection(HINDI_WORDS))

def split_mixed_paragraph(paragraph_text):
    lines = [line.strip() for line in paragraph_text.split('\n') if line.strip()]
    if not lines:
        return ""
    
    # If the paragraph is entirely Hindi translation, skip it
    if all(is_hindi_text(line) for line in lines):
        return ""
        
    sanskrit_lines = []
    for line in lines:
        words = {w for w in re.split(r'[\s।॥,.:;!?()（）\'\"\[\]\-–—+|\\/]+', line) if w}
        if words.intersection(HINDI_WORDS):
            # Hindi line - skip it
            continue
        else:
            if any(x in line for x in ['उवाच', 'राजोवाच', 'सूत', 'व्यास', 'मैत्रेय']):
                sanskrit_lines.append(line)
            else:
                sanskrit_lines.append(line)
                
    return "\n".join(sanskrit_lines).strip()

def extract_verse_number(text):
    text_stripped = text.strip()
    patterns = [
        re.compile(r'[॥।\s\|()（）\[\]\-\–]+([०-९\d]+(?:[-–][०-९\d]+)?)[॥।\s\|()（）\[\]\-\–]*$'),
        re.compile(r'\s+([०-९\d]+(?:[-–][०-९\d]+)?)\s*$'),
    ]
    for pat in patterns:
        m = pat.search(text_stripped)
        if m:
            return m.group(1)
            
    m = re.search(r'[॥।\|()（）\[\]]+([०-९\d]+(?:[-–][०-९\d]+)?)[॥।\|()（）\[\]]+', text_stripped)
    if m:
        return m.group(1)
    return None

def fetch_sitemap_urls(url, filename):
    cache_path = os.path.join(CACHE_DIR, filename)
    if os.path.exists(cache_path):
        with open(cache_path, 'r', encoding='utf-8') as f:
            xml_content = f.read()
    else:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'application/xml'
        }
        req = urllib.request.Request(url, headers=headers)
        try:
            with urllib.request.urlopen(req, timeout=30) as response:
                xml_content = response.read().decode('utf-8', errors='ignore')
            with open(cache_path, 'w', encoding='utf-8') as f:
                f.write(xml_content)
        except Exception as e:
            print(f"Error fetching sitemap {url}: {e}")
            return []
            
    xml_start = xml_content.find("<?xml")
    if xml_start != -1:
        xml_content = xml_content[xml_start:]
        
    try:
        root = ET.fromstring(xml_content)
        namespace = {"ns": "http://www.sitemaps.org/schemas/sitemap/0.9"}
        urls = []
        for url_node in root.findall("ns:url", namespace):
            loc_node = url_node.find("ns:loc", namespace)
            if loc_node is not None:
                urls.append(loc_node.text)
        return urls
    except Exception as e:
        # Fallback regex
        return re.findall(r'<loc>(.*?)</loc>', xml_content)

def fetch_html(url, cache_filename):
    cache_path = os.path.join(CACHE_DIR, cache_filename)
    if os.path.exists(cache_path):
        with open(cache_path, 'r', encoding='utf-8') as f:
            return f.read()

    unquoted = urllib.parse.unquote(url)
    parts = list(urllib.parse.urlsplit(unquoted))
    parts[2] = urllib.parse.quote(parts[2], safe='/')
    encoded_url = urllib.parse.urlunsplit(parts)
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    req = urllib.request.Request(encoded_url, headers=headers)
    
    time.sleep(0.15)  # Polite delay
    try:
        with urllib.request.urlopen(req, timeout=20) as response:
            html_content = response.read().decode('utf-8', errors='ignore')
        with open(cache_path, 'w', encoding='utf-8') as f:
            f.write(html_content)
        return html_content
    except Exception as e:
        print(f"Error fetching {url}: {e}")
        return None

def parse_page_shlokas(html_content):
    """General parser to extract shlokas (Sanskrit/Avadhi only) from page body."""
    title_match = re.search(r'<h1[^>]*>(.*?)</h1>', html_content, re.DOTALL)
    page_title = "Untitled"
    if title_match:
        page_title = clean_text(re.sub(r'<[^>]+>', '', title_match.group(1)))
        
    body_match = re.search(r'<div class="cm-entry-summary">(.*?)</div>\s*</article>', html_content, re.DOTALL) or \
                 re.search(r'<div class="entry-content">(.*?)</div>', html_content, re.DOTALL)
                 
    body_html = body_match.group(1) if body_match else html_content
    raw_paragraphs = re.findall(r'<p[^>]*>(.*?)</p>', body_html, re.DOTALL)
    
    shlokas = []
    shloka_dict = {}
    last_shloka_no = None
    
    dev_map = {'०':'0', '१':'1', '२':'2', '३':'3', '४':'4', '५':'5', '६':'6', '७':'7', '८':'8', '९':'9'}
    def to_eng_num(txt):
        return int("".join(dev_map.get(c, c) for c in txt))
        
    for p in raw_paragraphs:
        cleaned = clean_text(re.sub(r'<[^>]+>', '\n', p))
        if not cleaned or "Spread the Glory" in cleaned or "इति" in cleaned:
            continue
            
        sanskrit_part = split_mixed_paragraph(cleaned)
        if not sanskrit_part:
            continue
            
        num_str = extract_verse_number(cleaned)
        if num_str:
            base_num_str = num_str.split('-')[0].split('–')[0]
            try:
                shloka_no = to_eng_num(base_num_str)
                last_shloka_no = shloka_no
            except ValueError:
                # If no clean number, append as general line to last shloka or buffer
                if last_shloka_no is not None:
                    shloka_dict[last_shloka_no]["sanskrit"].append(sanskrit_part)
                continue
                
            if shloka_no not in shloka_dict:
                shloka_dict[shloka_no] = {"sanskrit": []}
            shloka_dict[shloka_no]["sanskrit"].append(sanskrit_part)
        else:
            # No number: append to last shloka if it exists
            if last_shloka_no is not None:
                shloka_dict[last_shloka_no]["sanskrit"].append(sanskrit_part)
                
    for shloka_no in sorted(shloka_dict.keys()):
        sanskrit = "\n".join(shloka_dict[shloka_no]["sanskrit"]).strip()
        # Verify it looks like a verse line
        if sanskrit and ("।" in sanskrit or "॥" in sanskrit or "[" in sanskrit or len(sanskrit) < 250):
            shlokas.append({
                "shloka_no": shloka_no,
                "sanskrit_text": sanskrit
            })
            
    return page_title, shlokas

def get_book_details(url):
    slug = urllib.parse.unquote(url).replace("https://www.ramcharit.in/", "").strip("/")
    
    # 1. Valmiki Ramayana
    if "valmiki-ramayana" in slug or "yuddhakanda-sarga" in slug or "balkanda-sarga" in slug:
        kands = {
            "balakanda": ("बालकाण्ड", 1), "bala-kanda": ("बालकाण्ड", 1), "balkanda": ("बालकाण्ड", 1),
            "ayodhyakanda": ("अयोध्याकाण्ड", 2), "ayodhya-kanda": ("अयोध्याकाण्ड", 2),
            "aranyakanda": ("अरण्यकाण्ड", 3), "aranya-kanda": ("अरण्यकाण्ड", 3),
            "kishkindhakanda": ("किष्किन्धाकाण्ड", 4), "kishkindha-kanda": ("किष्किन्धाकाण्ड", 4),
            "sundarakanda": ("सुन्दरकाण्ड", 5), "sundar-kanda": ("सुन्दरकाण्ड", 5),
            "yuddhakanda": ("युद्धकाण्ड", 6), "yuddha-kanda": ("युद्धकाण्ड", 6), "lankakanda": ("युद्धकाण्ड", 6), "lanka-kanda": ("युद्धकाण्ड", 6),
            "uttarakanda": ("उत्तरकाण्ड", 7), "uttara-kanda": ("उत्तरकाण्ड", 7), "uttar-kanda": ("उत्तरकाण्ड", 7),
        }
        kand_name, kand_num = ("बालकाण्ड", 1)
        for k, v in kands.items():
            if k in slug:
                kand_name, kand_num = v
                break
                
        # Sarga number
        sarga_match = re.search(r'(?:sarga-chapter|sarga|chapter)-(\d+)', slug, re.IGNORECASE)
        sarga_no = int(sarga_match.group(1)) if sarga_match else 99
        return "Valmiki Ramayana", {
            "kand_name": kand_name,
            "kand_num": kand_num,
            "sarga_no": sarga_no
        }
        
    # 2. Ramcharitmanas
    elif "bal-kand" in slug or "ayodhya-kand" in slug or "aranya-kand" in slug or "kishkindha-kand" in slug or "sundar-kand" in slug or "lanka-kand" in slug or "uttar-kand" in slug:
        kands = {
            "bal-kand": ("बालकाण्ड", 1), "ayodhya-kand": ("अयोध्याकाण्ड", 2), "aranya-kand": ("अरण्यकाण्ड", 3),
            "kishkindha-kand": ("किष्किन्धाकाण्ड", 4), "sundar-kand": ("सुन्दरकाण्ड", 5), "lanka-kand": ("लंकाकाण्ड", 6),
            "uttar-kand": ("उत्तरकाण्ड", 7)
        }
        kand_name, kand_num = ("बालकाण्ड", 1)
        for k, v in kands.items():
            if k in slug:
                kand_name, kand_num = v
                break
        return "Ramcharitmanas", {
            "kand_name": kand_name,
            "kand_num": kand_num
        }
        
    # 3. Durga Saptashati
    elif "durga-saptashati" in slug:
        ch_match = re.search(r'adhyay-(\d+)', slug)
        ch_no = int(ch_match.group(1)) if ch_match else 99
        return "Durga Saptashati", {
            "chapter_no": ch_no
        }
        
    # 4. Other general stotras / chalisa
    elif any(x in slug for x in ["chalisa", "stotra", "aarti", "nama", "stuti", "rudrashtakam", "panchakam", "saptashati"]):
        return "Stotra", {}
        
    return None, {}

def process_url(url):
    book_type, details = get_book_details(url)
    if not book_type:
        return None
        
    # Standardize cache filename
    slug = urllib.parse.unquote(url).replace("https://www.ramcharit.in/", "").strip("/").replace("/", "_")
    cache_filename = f"post_{slug}.html"
    
    html_content = fetch_html(url, cache_filename)
    if not html_content:
        return None
        
    try:
        page_title, shlokas = parse_page_shlokas(html_content)
        if not shlokas:
            return None
            
        return {
            "url": url,
            "book_type": book_type,
            "details": details,
            "page_title": page_title,
            "shlokas": shlokas
        }
    except Exception as e:
        print(f"Error processing URL {url}: {e}")
        return None

def main():
    print("Starting crawl of all ramcharit.in library pages...")
    start_time = time.time()
    
    urls1 = fetch_sitemap_urls("https://www.ramcharit.in/post-sitemap.xml", "post-sitemap.xml")
    urls2 = fetch_sitemap_urls("https://www.ramcharit.in/post-sitemap2.xml", "post-sitemap2.xml")
    all_urls = sorted(list(set(urls1 + urls2)))
    
    print(f"Total discovered sitemap URLs: {len(all_urls)}")
    
    # Filter only relevant URLs based on book type
    target_urls = []
    for u in all_urls:
        bt, _ = get_book_details(u)
        if bt and "shrimad-bhagwat" not in u and "bhagavatam" not in u: # Exclude Bhagwat (already scraped)
            target_urls.append(u)
            
    print(f"Queueing {len(target_urls)} book and stotra pages for parallel scraping...")
    
    scraped_data = []
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = {executor.submit(process_url, url): url for url in target_urls}
        for future in as_completed(futures):
            res = future.result()
            if res:
                scraped_data.append(res)
                
    print(f"Scraping completed! Successfully parsed {len(scraped_data)} content pages.")
    
    new_items = []
    
    # Map Hindi Kand numbers
    HINDI_SKANDHAS = {
        1: "प्रथम", 2: "द्वितीय", 3: "तृतीय", 4: "चतुर्थ", 5: "पंचम", 6: "षष्ठ", 7: "सप्तम"
    }
    
    for item in scraped_data:
        bt = item["book_type"]
        details = item["details"]
        page_title = item["page_title"]
        
        # Clean title suffix (e.g. "with Hindi meaning")
        clean_page_title = re.sub(r'with Hindi Meaning.*$', '', page_title, flags=re.IGNORECASE).strip()
        clean_page_title = re.sub(r'slokas with.*$', '', clean_page_title, flags=re.IGNORECASE).strip()
        
        for s in item["shlokas"]:
            sh_no = s["shloka_no"]
            sanskrit = s["sanskrit_text"]
            
            item_id = str(uuid.uuid4())
            
            if bt == "Valmiki Ramayana":
                k_name = details["kand_name"]
                k_num = details["kand_num"]
                s_no = details["sarga_no"]
                k_hindi = HINDI_SKANDHAS.get(k_num, "बालकाण्ड")
                
                title = f"वाल्मीकि रामायण, {k_name}, सर्ग {s_no}, श्लोक {sh_no}"
                slug = f"valmiki-ramayana-{k_num}-sarga-{s_no}-shlok-{sh_no}"
                author = "महर्षि वाल्मीकि, रामायण"
                tags = ["वाल्मीकि रामायण", f"{k_hindi} काण्ड", f"सर्ग {s_no}", clean_page_title]
                
            elif bt == "Ramcharitmanas":
                k_name = details["kand_name"]
                k_num = details["kand_num"]
                k_hindi = HINDI_SKANDHAS.get(k_num, "बालकाण्ड")
                
                title = f"रामचरितमानस, {k_name}, दोहा/चौपाई {sh_no}"
                slug = f"ramcharitmanas-kand-{k_num}-doha-{sh_no}"
                author = "गोस्वामी तुलसीदास, रामचरितमानस"
                tags = ["रामचरितमानस", f"{k_hindi} काण्ड", clean_page_title]
                
            elif bt == "Durga Saptashati":
                ch_no = details["chapter_no"]
                title = f"दुर्गा सप्तशती, अध्याय {ch_no}, श्लोक {sh_no}"
                slug = f"durga-saptashati-adhyay-{ch_no}-shlok-{sh_no}"
                author = "वेदव्यास, दुर्गा सप्तशती"
                tags = ["दुर्गा सप्तशती", f"अध्याय {ch_no}", clean_page_title]
                
            else: # Stotra
                title = f"{clean_page_title}, श्लोक {sh_no}"
                slug = f"stotra-{item_id[:8]}-shlok-{sh_no}"
                author = "पारंपरिक"
                tags = ["स्तोत्र संग्रह", clean_page_title]
                
            content_item = {
                "id": item_id,
                "title": title,
                "sanskrit_text": sanskrit,
                "hindi_text": "",  # Omit Hindi to prevent copyright strikes
                "english_text": "",
                "english_translation": "",
                "category": "Shloka",
                "description": "",
                "content_text": "",
                "tags": tags,
                "status": "published",
                "author": author,
                "slug": slug
            }
            new_items.append(content_item)
            
    print(f"Scrape phase complete: compiled {len(new_items)} new shloka entries.")
    
    # Merge with existing vrindavaani_content.json
    if os.path.exists(OUTPUT_FILE):
        try:
            with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)
                
            # Filter out any old Valmiki Ramayana, Ramcharitmanas, Durga Saptashati, and Stotras
            clean_existing = []
            for item in existing_data:
                tags = item.get("tags", [])
                is_old_target = any(x in tags for x in ["वाल्मीकि रामायण", "रामचरितमानस", "दुर्गा सप्तशती", "स्तोत्र संग्रह"])
                if not is_old_target:
                    clean_existing.append(item)
                    
            merged_data = clean_existing + new_items
            print(f"Merging: {len(clean_existing)} original items + {len(new_items)} new items = {len(merged_data)} total items.")
            
            with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
                json.dump(merged_data, f, ensure_ascii=False, indent=2)
                
            print(f"Successfully saved merged database to {OUTPUT_FILE}!")
        except Exception as e:
            print(f"Failed to merge data: {e}")
    else:
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            json.dump(new_items, f, ensure_ascii=False, indent=2)
            
    print(f"Total time elapsed: {time.time() - start_time:.2f} seconds.")

if __name__ == '__main__':
    main()
