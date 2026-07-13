import json
import os
import time
import urllib.parse
import subprocess
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
import requests
from requests.adapters import HTTPAdapter

BASE_DIR = Path(__file__).parent.parent.parent
DB_PATH = BASE_DIR / 'frontend/data/vrindavaani_content.json'
CHECKPOINT_PATH = Path(__file__).parent / 'paraphrase_checkpoint.json'

# Setup HTTP session with pooling for concurrent requests
session = requests.Session()
adapter = HTTPAdapter(pool_connections=20, pool_maxsize=20)
session.mount('https://', adapter)

def translate_via_google_single(text, from_lang, to_lang):
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
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    
    max_retries = 5
    backoff = 2
    for attempt in range(max_retries):
        try:
            resp = session.get(url, params=params, headers=headers, timeout=12)
            if resp.status_code == 200:
                res = resp.json()
                return "".join([part[0] for part in res[0] if part[0]])
            elif resp.status_code == 429:
                print(f"⚠️ Rate limited (429) for text (len={len(text)}). Retrying in {backoff}s...", flush=True)
            else:
                print(f"⚠️ Translation HTTP {resp.status_code} for text (len={len(text)}). Retrying...", flush=True)
        except Exception as e:
            print(f"⚠️ Translation attempt {attempt+1} failed: {e}. Retrying...", flush=True)
        time.sleep(backoff)
        backoff *= 2
        
    return None

def translate_via_google(text, from_lang, to_lang):
    if not text or not text.strip():
        return ""
    
    # If the text is long, chunk it to avoid HTTP 400/413 limits
    if len(text) > 800:
        lines = text.split('\n')
        translated_chunks = []
        for line in lines:
            if not line.strip():
                translated_chunks.append("")
                continue
            if len(line) > 800:
                # Split further by sentences/punctuation
                import re
                sentences = re.split(r'([.!?।॥])', line)
                sub_chunks = []
                current_chunk = ""
                for part in sentences:
                    if len(current_chunk) + len(part) < 800:
                        current_chunk += part
                    else:
                        if current_chunk.strip():
                            sub_chunks.append(translate_via_google_single(current_chunk, from_lang, to_lang) or current_chunk)
                        current_chunk = part
                if current_chunk.strip():
                    sub_chunks.append(translate_via_google_single(current_chunk, from_lang, to_lang) or current_chunk)
                translated_chunks.append("".join(sub_chunks))
            else:
                translated_chunks.append(translate_via_google_single(line, from_lang, to_lang) or line)
        return "\n".join(translated_chunks)
    else:
        return translate_via_google_single(text, from_lang, to_lang)

def paraphrase_hindi_roundtrip(text):
    if not text or not text.strip():
        return ""
    # 1. Translate Hindi to English
    english = translate_via_google(text, 'hi', 'en')
    if not english:
        return None
    # 2. Translate English back to Hindi
    paraphrased = translate_via_google(english, 'en', 'hi')
    return paraphrased

def clean_paraphrased_text(text):
    if not text:
        return ""
    # Post-process for spiritual/literary accuracy
    text = text.replace('स्वाद कलिकाओं', 'रसिकों की रसना (वाणी)')
    text = text.replace('स्वाद कलिका', 'वाणी')
    text = text.replace('इन्द्रियतृप्ति', 'विषय-वासना')
    text = text.replace('इंद्रियतृप्ति', 'विषय-वासना')
    text = text.replace('राजा-रेणुका', 'चरण-रज')
    return text

def main():
    if not DB_PATH.exists():
        print(f"❌ Error: Database file not found at {DB_PATH}", flush=True)
        return

    print(f"Loading database from {DB_PATH}...", flush=True)
    with open(DB_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f"Loaded {len(data)} records.", flush=True)

    # Load checkpoint
    processed_ids = set()
    if CHECKPOINT_PATH.exists():
        try:
            with open(CHECKPOINT_PATH, 'r', encoding='utf-8') as f:
                checkpoint_data = json.load(f)
                processed_ids = set(checkpoint_data.get('processed_ids', []))
            print(f"Loaded checkpoint. Already processed {len(processed_ids)} items.", flush=True)
        except Exception as e:
            print(f"⚠️ Warning: Failed to load checkpoint: {e}", flush=True)

    # Filter items that have hindi_text and are not processed
    items_to_process = []
    for item in data:
        item_id = item.get('id')
        hindi = (item.get('hindi_text') or '').strip()
        if hindi and item_id not in processed_ids:
            items_to_process.append(item)

    total_to_process = len(items_to_process)
    print(f"Total items remaining to process: {total_to_process}", flush=True)

    if total_to_process == 0:
        print("🎉 All items already paraphrased!", flush=True)
        return

    # Track updates locally
    id_to_item = {item['id']: item for item in data}
    completed_count = 0
    save_batch_size = 50

    def worker(item):
        item_id = item['id']
        hindi = item['hindi_text'].strip()
        
        # Delay slightly to space out requests nicely
        time.sleep(0.3)
        
        paraphrased = paraphrase_hindi_roundtrip(hindi)
        if paraphrased:
            paraphrased = clean_paraphrased_text(paraphrased)
            return item_id, paraphrased
        return item_id, None

    # Process in a thread pool
    max_workers = 10
    print(f"Starting paraphrasing using ThreadPoolExecutor with {max_workers} workers...", flush=True)
    
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        future_to_item = {executor.submit(worker, item): item for item in items_to_process}
        
        for future in as_completed(future_to_item):
            item = future_to_item[future]
            item_id, paraphrased = future.result()
            
            if paraphrased:
                # Update item in the main data map
                db_item = id_to_item[item_id]
                db_item['hindi_text'] = paraphrased
                
                # Rebuild content_text
                parts = []
                if db_item.get('sanskrit_text'):
                    parts.append(db_item['sanskrit_text'])
                if db_item.get('author') and db_item.get('author') != 'Team VrindaVaani':
                    parts.append(f"- {db_item['author']}")
                parts.append(db_item['hindi_text'])
                db_item['content_text'] = "\n".join(parts)
                
                # Wipe copyrighted English fields for DMCA compliance
                db_item["english_text"] = ""
                db_item["english_translation"] = ""
                db_item["description"] = ""

                processed_ids.add(item_id)
                completed_count += 1
                
                if completed_count % 10 == 0:
                    print(f"Processed {completed_count}/{total_to_process} items in this run.", flush=True)

                # Periodic checkpoint save
                if completed_count % save_batch_size == 0:
                    print(f"💾 Saving batch checkpoint at {completed_count}...", flush=True)
                    # Save DB
                    with open(DB_PATH, 'w', encoding='utf-8') as f:
                        json.dump(data, f, ensure_ascii=False, indent=2)
                    # Save Checkpoint file
                    with open(CHECKPOINT_PATH, 'w', encoding='utf-8') as f:
                        json.dump({'processed_ids': list(processed_ids)}, f, ensure_ascii=False, indent=2)
            else:
                print(f"❌ Failed to paraphrase ID: {item_id}", flush=True)

    # Final Save
    print("💾 Saving final database...", flush=True)
    with open(DB_PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        
    with open(CHECKPOINT_PATH, 'w', encoding='utf-8') as f:
        json.dump({'processed_ids': list(processed_ids)}, f, ensure_ascii=False, indent=2)
        
    print("🎉 Paraphrasing completed successfully!", flush=True)

if __name__ == '__main__':
    main()
