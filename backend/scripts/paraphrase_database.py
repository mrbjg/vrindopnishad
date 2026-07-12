import os
import json
import re
import time
import urllib.request
import urllib.parse
import requests
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client
from concurrent.futures import ThreadPoolExecutor
from requests.adapters import HTTPAdapter

# Load environment
SCRIPT_DIR = Path(__file__).parent
BACKEND_DIR = SCRIPT_DIR.parent
load_dotenv(BACKEND_DIR / '.env')

# Supabase Client Setup
url = os.environ.get('SUPABASE_URL', '')
key = os.environ.get('SUPABASE_SERVICE_ROLE_KEY') or os.environ.get('SUPABASE_ANON_KEY', '')
supabase_client = create_client(url, key)

# Google Translate API Helpers with Connection Pooling
session = requests.Session()
adapter = HTTPAdapter(pool_connections=50, pool_maxsize=50)
session.mount('https://', adapter)

def translate_text_single(text, from_lang, to_lang):
    if not text or not text.strip():
        return ""
    
    url = "https://translate.googleapis.com/translate_a/single"
    params = {
        'client': 'gtx',
        'sl': from_lang,
        'tl': to_lang,
        'dt': 't',
        'q': text
    }
    headers = {
        'User-Agent': 'Mozilla/5.0'
    }
    
    for attempt in range(4):
        try:
            resp = session.get(url, params=params, headers=headers, timeout=15)
            if resp.status_code == 200:
                res = resp.json()
                return "".join([item[0] for item in res[0] if item[0]])
            else:
                print(f"Translation HTTP {resp.status_code} for text (len={len(text)}). Retrying...", flush=True)
        except Exception as e:
            # Check if DNS or network error
            print(f"Translation attempt {attempt+1} failed for text (len={len(text)}): {e}. Retrying...", flush=True)
        time.sleep(0.2 * (attempt + 1))
        
    print(f"Failed to translate text after 4 attempts. Returning original text.", flush=True)
    return text

def translate_text(text, from_lang, to_lang):
    if not text or not text.strip():
        return ""
    
    # If the text is long, chunk it to avoid HTTP 400 URL length limits
    if len(text) > 800:
        lines = text.split('\n')
        translated_chunks = []
        for line in lines:
            if not line.strip():
                translated_chunks.append("")
                continue
            if len(line) > 800:
                # Split further by sentences/punctuation
                sentences = re.split(r'([.!?।])', line)
                sub_chunks = []
                current_chunk = ""
                for part in sentences:
                    if len(current_chunk) + len(part) < 800:
                        current_chunk += part
                    else:
                        if current_chunk.strip():
                            sub_chunks.append(translate_text_single(current_chunk, from_lang, to_lang))
                        current_chunk = part
                if current_chunk.strip():
                    sub_chunks.append(translate_text_single(current_chunk, from_lang, to_lang))
                translated_chunks.append("".join(sub_chunks))
            else:
                translated_chunks.append(translate_text_single(line, from_lang, to_lang))
        return "\n".join(translated_chunks)
    else:
        return translate_text_single(text, from_lang, to_lang)

def paraphrase_via_translate(text, from_lang, to_lang):
    inter = translate_text(text, from_lang, to_lang)
    back = translate_text(inter, to_lang, from_lang)
    return back

def paraphrase_item_fallback(item):
    item_id = item['id']
    hindi_para = ""
    if item.get('hindi_text'):
        hindi_para = paraphrase_via_translate(item['hindi_text'], 'hi', 'en')
    english_para = ""
    if item.get('english_translation'):
        english_para = paraphrase_via_translate(item['english_translation'], 'en', 'hi')
    return item_id, hindi_para, english_para

# Gemini API Key Setup
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY') or 'AQ.Ab8RN6IrgILt-txnWDb7xpowWh5zdGcYrx8gL6x2mEULZy0IkQ'
GEMINI_URL = f'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={GEMINI_API_KEY}'

# Parsing Keywords for Hindi
ref_keywords_hi = ['श्री', 'जगद्गुरु', 'स्वामी', 'रानी', 'गोस्वामी', 'भगवत्', 'संत', 'Biharin', 'Sri', 'Shri', 'Jagadguru', 'Hit', 'Harivansh', 'Vyas', 'Dhruvdas', 'Roop', 'Lal', 'Bhatt', 'Rasnidhi', 'Gopal', 'Chhit', 'Nanddas', 'Surdas', 'Kumbhandas', 'Krishnadas', 'Govind', 'Chaturbhuj', 'Haridas', 'Albeli', 'Yugal', 'Kripalu', 'Rup', 'Sanatana', 'Jiva', 'Raghunatha', 'Gopala', 'Prabodhanand', 'Vrindavan', 'Braj', 'ब्रज', 'रस', 'माधुरी', 'दोहे', 'दोहा', 'कृपालु', 'नागरी', 'सेवक', 'ललित', 'सूरदास', 'सूर', 'कबीर', 'तुलसीदास', 'बिहारी', 'हित', 'व्यास', 'ध्रुवदास', 'हरिदास', 'चतुर्भुज', 'नंददास', 'कृष्ण', 'राधा', 'गोविंद']
saint_suffixes_hi = ['जी', 'जीओ', 'दास', 'दासी', 'देव', 'देवी', 'बाई', 'माधुरी', 'महाराज', 'स्वामी', 'आचार्य', 'भट्ट', 'प्रभु', 'हरिवंश', 'व्यास', 'निधि', 'अलि', 'अली', 'शरण', 'कुँवरि', 'कुंवरि', 'बलबीर', 'प्रिया']
book_keywords_hi = ['वाणी', 'वाणीजी', 'ग्रंथावली', 'ग्रन्थावली', 'शतक', 'साखी', 'लीला', 'लता', 'संग्रह', 'सुधानिधि', 'सप्तशती', 'दोहा', 'कविता', 'सवैया', 'पद', 'अष्टक', 'महिमामृत', 'चतुरासी', 'विनोद', 'वल्लभ', 'सिद्धान्त', 'साखि']
translation_start_words_hi = ['श्री', 'श्रीराधा', 'श्रीकृष्ण', 'श्रीराधे', 'इस', 'ओ', 'हे', 'मैं', 'जब', 'सभी', 'हम', 'यह', 'वे', 'यदि', 'जिस', 'बाँके', 'ओ', 'प्यारे', 'लाल', 'प्रिय', 'सखी', 'वृंदावन', 'यमुना', 'श्रीकृष्ण', 'कृष्ण', 'राधा', 'राधे', 'श्यामा', 'श्याम', 'तुम', 'आप', 'यहाँ', 'वहाँ', 'तहाँ', 'कहा', 'कहे', 'कहते', 'कहती']

# Parsing Keywords for English
ref_keywords_en = ['Sri', 'Shri', 'Jagadguru', 'Swami', 'Rani', 'Goswami', 'Bhagwat', 'Sant', 'Biharin', 'Hit', 'Harivansh', 'Vyas', 'Dhruvdas', 'Roop', 'Lal', 'Bhatt', 'Rasnidhi', 'Gopal', 'Chhit', 'Nanddas', 'Surdas', 'Kumbhandas', 'Krishnadas', 'Govind', 'Chaturbhuj', 'Haridas', 'Albeli', 'Yugal', 'Kripalu', 'Rup', 'Sanatana', 'Jiva', 'Raghunatha', 'Gopala', 'Prabodhanand', 'Vrindavan', 'Braj', 'Doha', 'Dohe', 'Kavita', 'Sawaiya', 'Pad', 'Ashtak', 'Vani', 'Granthawali', 'Granthavali']
saint_suffixes_en = ['Ji', 'Jio', 'Das', 'Dasi', 'Dev', 'Devi', 'Bai', 'Maharaj', 'Swami', 'Acharya', 'Bhatt', 'Prabhu', 'Harivansh', 'Vyas', 'Nidhi', 'Ali', 'Sharan', 'Kunwari', 'Balbeer', 'Priya']
book_keywords_en = ['Vani', 'Granthawali', 'Granthavali', 'Shatak', 'Saakhi', 'Sakhi', 'Leela', 'Lata', 'Sangrah', 'Sudhanidhi', 'Saptashati', 'Doha', 'Kavita', 'Sawaiya', 'Pad', 'Ashtak', 'Mahamamrit', 'Chaurasi', 'Chaturasi', 'Vinod', 'Vallabh', 'Siddhant']
translation_start_words_en = ['Sri', 'Shri', 'Radha', 'Krishna', 'Radhe', 'Devotion', 'This', 'O', 'Oh', 'I', 'When', 'All', 'We', 'It', 'They', 'If', 'Which', 'Banke', 'Dear', 'Beloved', 'Friend', 'Vrindavan', 'Yamuna', 'Krishna', 'Krishn', 'Radha', 'Radhe', 'Shyama', 'Shyam', 'You', 'Here', 'There', 'Said', 'Says', 'Saints']

def split_content_generic(text, ref_keywords, saint_suffixes, book_keywords, translation_start_words):
    if not text or not text.strip():
        return None
    pattern = r'-\s*(?:' + '|'.join(ref_keywords) + r')'
    matches = list(re.finditer(pattern, text, re.IGNORECASE))
    if not matches:
        return None
    
    match = matches[0]
    split_idx = match.start()
    verse = text[:split_idx].strip()
    after = text[split_idx:].strip()
    if after.startswith('-'):
        after = after[1:].strip()
        
    first_line = after.split('\n')[0].strip()
    parts = [p.strip() for p in first_line.split(',')]
    
    ref_parts = []
    translation_part = None
    
    first_part = parts[0]
    first_part_words = first_part.split()
    clean_first_part_words = []
    translation_words = []
    found_saint_end = False
    
    for i, w in enumerate(first_part_words):
        clean_first_part_words.append(w)
        w_clean = w.strip('.,?!\'\"();:।॥-—•').lower()
        if w_clean in [s.lower() for s in saint_suffixes]:
            found_saint_end = True
            translation_words = first_part_words[i+1:]
            break
            
    if found_saint_end:
        ref_parts.append(' '.join(clean_first_part_words))
        if translation_words:
            translation_part = ' '.join(translation_words)
    else:
        ref_words = []
        for i, w in enumerate(first_part_words):
            w_clean = w.strip('.,?!\'\"();:।॥-—•').lower()
            if len(ref_words) >= 2 and w_clean in [t.lower() for t in translation_start_words]:
                translation_words = first_part_words[i:]
                break
            ref_words.append(w)
        ref_parts.append(' '.join(ref_words))
        if translation_words:
            translation_part = ' '.join(translation_words)
            
    # Process remaining parts
    for p in parts[1:]:
        if translation_part is not None:
            translation_part += ', ' + p
        else:
            p_clean = p.strip('.,?!\'\"();:।॥-—•').lower()
            is_book = any(k.lower() in p_clean for k in book_keywords) or bool(re.search(r'\d+', p))
            if is_book:
                ref_parts.append(p)
            else:
                translation_part = p
                
    ref = ', '.join(ref_parts)
    lines = after.split('\n')
    translation_lines = []
    if translation_part:
        translation_lines.append(translation_part)
    translation_lines.extend(lines[1:])
    translation = '\n'.join(translation_lines).strip()
    translation = re.sub(r'^[,\.\s\-\:]+', '', translation).strip()
    
    return verse, ref, translation

def split_by_danda(text, start_words, is_english=False):
    if not text or not text.strip():
        return None
    punctuation_pattern = r'[.!?]' if is_english else r'[।॥.!?]'
    pattern = r'(' + punctuation_pattern + r'|\]|\)\s*)\s+(?=' + '|'.join(start_words) + r'\b)'
    matches = list(re.finditer(pattern, text, re.IGNORECASE if is_english else 0))
    if not matches:
        return None
    for match in matches:
        split_idx = match.end(1)
        verse = text[:split_idx].strip()
        translation = text[split_idx:].strip()
        if len(translation) > 20:
            return verse, '', translation
    return None

def clean_author(ref):
    if not ref:
        return 'Team VrindaVaani'
    parts = ref.split(',')
    saint = parts[0].strip()
    saint = re.sub(r'^[-\s\•]+', '', saint).strip()
    if len(saint) < 3 or len(saint) > 50:
        return 'Team VrindaVaani'
    return saint

def call_gemini_batch(items_batch):
    prompt = f'''
You are a translation assistant. You are given a JSON array of translations of devotional spiritual verses of the saints of Vrindavan.
Your task is to rewrite/paraphrase the Hindi and English translations more beautifully, poetically, and naturally.
Ensure that:
1. The meaning and spiritual essence of the original translations are fully preserved.
2. The vocabulary and phrasing are modified to be unique and legally distinct from the original (avoid copyright issues).
3. Technical terms like "रसिक भक्त" (Rasik devotees), names of saints, and names of places (Vrindavan, Barsana, Yamuna, etc.) are preserved exactly.
4. Return ONLY a valid JSON array of objects, containing the keys: "id", "hindi_text", and "english_translation".

Input JSON:
{json.dumps(items_batch, ensure_ascii=False)}
'''
    schema = {
        'type': 'ARRAY',
        'items': {
            'type': 'OBJECT',
            'properties': {
                'id': {'type': 'STRING'},
                'hindi_text': {'type': 'STRING'},
                'english_translation': {'type': 'STRING'}
            },
            'required': ['id', 'hindi_text', 'english_translation']
        }
    }
    payload = {
        'contents': [{'parts': [{'text': prompt}]}],
        'generationConfig': {
            'responseMimeType': 'application/json',
            'responseSchema': schema
        }
    }
    
    req = urllib.request.Request(GEMINI_URL, data=json.dumps(payload).encode('utf-8'), headers={'Content-Type': 'application/json'})
    for attempt in range(8):
        try:
            with urllib.request.urlopen(req) as response:
                res = json.loads(response.read().decode('utf-8'))
                content = res['candidates'][0]['content']['parts'][0]['text']
                return json.loads(content)
        except Exception as e:
            # Skip retries immediately on authentication or quota errors
            if hasattr(e, 'code') and e.code in (401, 403, 429):
                print(f"Gemini API returned status {e.code}. Skipping retries.", flush=True)
                raise e
            wait_time = 2 ** attempt
            print(f'Gemini attempt {attempt+1} failed: {e}. Retrying in {wait_time}s...', flush=True)
            time.sleep(wait_time)
            
    raise Exception("Failed to call Gemini after 8 attempts")

def main():
    db_path = Path(__file__).parent.parent.parent / 'frontend/data/vrindavaani_content.json'
    cache_path = Path(__file__).parent.parent.parent / 'frontend/data/paraphrase_cache.json'
    
    if not db_path.exists():
        print(f"Error: Database file not found at {db_path}", flush=True)
        return
        
    print(f"Loading database from {db_path}...", flush=True)
    with open(db_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f"Loaded {len(data)} records.", flush=True)
    
    # 1. Parse and format the records (Filter out mixed verses)
    print("Filtering and formatting mixed verses...", flush=True)
    parsed_count = 0
    for item in data:
        sanskrit = (item.get('sanskrit_text') or '').strip()
        hindi = (item.get('hindi_text') or '').strip()
        english = (item.get('english_translation') or '').strip()
        
        if not sanskrit:
            res_hi = split_content_generic(hindi, ref_keywords_hi, saint_suffixes_hi, book_keywords_hi, translation_start_words_hi)
            if not res_hi:
                res_hi = split_by_danda(hindi, translation_start_words_hi)
                
            if res_hi:
                parsed_count += 1
                verse_hi, ref_hi, trans_hi = res_hi
                item['sanskrit_text'] = verse_hi
                item['hindi_text'] = trans_hi
                
                current_author = (item.get('author') or '').strip()
                if ref_hi and current_author in ['', 'Team VrindaVaani', 'General', 'Shloka']:
                    item['author'] = clean_author(ref_hi)
                    
                res_en = split_content_generic(english, ref_keywords_en, saint_suffixes_en, book_keywords_en, translation_start_words_en)
                if not res_en:
                    res_en = split_by_danda(english, translation_start_words_en, is_english=True)
                    
                if res_en:
                    _, _, trans_en = res_en
                    item['english_translation'] = trans_en
                    item['english_text'] = trans_en
                    
    print(f"Cleaned and split {parsed_count} records containing mixed verses/attributions.", flush=True)
    
    # Save the split formatting changes first
    with open(db_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        
    # 2. Load paraphrase cache
    cache = {}
    if cache_path.exists():
        with open(cache_path, 'r', encoding='utf-8') as f:
            cache = json.load(f)
        print(f"Resuming from cache with {len(cache)} already paraphrased items.", flush=True)
        
    # 3. Collect items that need paraphrasing
    to_paraphrase = []
    for item in data:
        item_id = item['id']
        if item_id in cache:
            continue
            
        hindi = (item.get('hindi_text') or '').strip()
        english = (item.get('english_translation') or '').strip()
        
        if not hindi and not english:
            continue
            
        to_paraphrase.append({
            'id': item_id,
            'hindi_text': hindi,
            'english_translation': english
        })
        
    total_to_process = len(to_paraphrase)
    print(f"Total items needing paraphrasing: {total_to_process}", flush=True)
    
    # 4. Paraphrase sequentially
    batch_size = 100
    processed = 0
    print(f"Starting sequential paraphrasing with batch size {batch_size}...", flush=True)
    
    for i in range(0, total_to_process, batch_size):
        batch = to_paraphrase[i:i+batch_size]
        print(f"Processing batch {i//batch_size + 1}/{(total_to_process-1)//batch_size + 1} (Size={len(batch)})...", flush=True)
        
        try:
            results = call_gemini_batch(batch)
            for res_item in results:
                cache[res_item['id']] = {
                    'hindi_text': res_item['hindi_text'],
                    'english_translation': res_item['english_translation']
                }
            processed += len(batch)
            time.sleep(4.0)
        except Exception as e:
            print(f"⚠️ Gemini failed for batch starting at index {i} ({e}). Falling back to Google Translate back-translation in parallel...", flush=True)
            with ThreadPoolExecutor(max_workers=20) as executor:
                futures = [executor.submit(paraphrase_item_fallback, item) for item in batch]
                for future in futures:
                    try:
                        item_id, hindi_para, english_para = future.result()
                        cache[item_id] = {
                            'hindi_text': hindi_para,
                            'english_translation': english_para
                        }
                    except Exception as ex:
                        print(f"Error in parallel fallback translation: {ex}", flush=True)
            processed += len(batch)
            
        # Periodically write cache to disk
        with open(cache_path, 'w', encoding='utf-8') as f:
            json.dump(cache, f, ensure_ascii=False, indent=2)
            
        print(f"Paraphrased {processed + len(data) - total_to_process}/{len(data)} items.", flush=True)
            
    # 5. Merge cached data back to main dataset and save
    print("Merging paraphrased translations back into main dataset...", flush=True)
    updated_supabase_records = []
    for item in data:
        item_id = item['id']
        if item_id in cache:
            item['hindi_text'] = cache[item_id]['hindi_text']
            item['english_translation'] = cache[item_id]['english_translation']
            item['english_text'] = cache[item_id]['english_translation']
            
        updated_supabase_records.append({
            'id': item['id'],
            'title': item.get('title'),
            'sanskrit_text': item.get('sanskrit_text'),
            'hindi_text': item.get('hindi_text'),
            'english_text': item.get('english_text'),
            'english_translation': item.get('english_translation'),
            'category': item.get('category', 'poem'),
            'description': item.get('description'),
            'audio_url': item.get('audio_url'),
            'image_urls': item.get('image_urls', []),
            'video_urls': item.get('video_urls', []),
            'created_at': item.get('created_at'),
            'updated_at': item.get('updated_at'),
            'content_text': item.get('content_text'),
            'tags': item.get('tags', []),
            'status': item.get('status', 'published'),
            'author': item.get('author', 'Team VrindaVaani'),
            'media_links': item.get('media_links', []),
            'slug': item.get('slug')
        })
        
    print(f"Saving final database locally to {db_path}...", flush=True)
    with open(db_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        
    # 6. Upload updates to Supabase
    print(f"Uploading updates to Supabase database ({len(updated_supabase_records)} records)...", flush=True)
    batch_upload_size = 100
    uploaded_count = 0
    for i in range(0, len(updated_supabase_records), batch_upload_size):
        batch = updated_supabase_records[i:i+batch_upload_size]
        try:
            supabase_client.table('content').upsert(batch).execute()
            uploaded_count += len(batch)
            if uploaded_count % 500 == 0 or uploaded_count == len(updated_supabase_records):
                print(f"Supabase progress: {uploaded_count}/{len(updated_supabase_records)} uploaded.", flush=True)
        except Exception as e:
            print(f"❌ Failed to upsert batch {i//batch_upload_size} in Supabase: {e}", flush=True)
            
    print("🎉 Paraphrasing and database sync complete!", flush=True)
    
    if cache_path.exists():
        try:
            os.remove(cache_path)
            print("Removed temporary cache file.", flush=True)
        except Exception as e:
            print(f"Failed to remove cache file: {e}", flush=True)
            
    # 7. Run post-sync cache generation and backup export
    print("Running sync_cache.mjs and export_supabase_to_frontend.py...", flush=True)
    import subprocess
    try:
        subprocess.run(['node', 'frontend/scripts/sync_cache.mjs'], cwd=BACKEND_DIR.parent, check=True)
        subprocess.run(['python3', 'backend/scripts/export_supabase_to_frontend.py'], cwd=BACKEND_DIR.parent, check=True)
        print("🎉 Frontend caches and backup splits regenerated successfully!", flush=True)
    except Exception as e:
        print(f"❌ Failed to run post-sync scripts: {e}", flush=True)

if __name__ == '__main__':
    main()
