import json
import urllib.request
import time
import re
import os
import subprocess
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent.parent
DB_PATH = BASE_DIR / 'frontend/data/vrindavaani_content.json'
CACHE_PATH = BASE_DIR / 'frontend/data/beautify_cache.json'

env_key = os.environ.get('GEMINI_API_KEY') or os.environ.get('REACT_APP_GEMINI_API_KEY')
if not env_key:
    # Try reading from backend/.env
    env_path = BASE_DIR / 'backend/.env'
    if env_path.exists():
        with open(env_path, 'r', encoding='utf-8') as f:
            for line in f:
                if line.strip().startswith('GEMINI_API_KEY='):
                    env_key = line.strip().split('=', 1)[1].strip().strip('"').strip("'")
                    break

API_KEY = env_key or 'AQ.Ab8RN6ISfxlOzzqkxqjaXsseTIP6XVHKK2yTjCCfmVFpxvMyvQ'

def call_gemini_batch(items_batch):
    url = f'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={API_KEY}'
    
    prompt = f'''
You are an expert specializing in Braj Rasika literature and Vedic devotional texts.
Translate the Sanskrit or Braj Bhasha verse ("sanskrit_text") into a spiritually accurate, poetic, and natural Hindi prose explanation.
Preserve terms like "रसिक भक्त", names of saints, and places (Vrindavan, Barsana, Yamuna) exactly.
Output ONLY a JSON array of objects with keys "id" and "hindi_text".

Input JSON:
{json.dumps(items_batch, ensure_ascii=False)}
'''

    schema = {
        'type': 'ARRAY',
        'items': {
            'type': 'OBJECT',
            'properties': {
                'id': {'type': 'STRING'},
                'hindi_text': {'type': 'STRING'}
            },
            'required': ['id', 'hindi_text']
        }
    }
    
    payload = {
        'contents': [{'parts': [{'text': prompt}]}],
        'generationConfig': {
            'responseMimeType': 'application/json',
            'responseSchema': schema
        }
    }
    
    req = urllib.request.Request(
        url, 
        data=json.dumps(payload).encode('utf-8'), 
        headers={'Content-Type': 'application/json'}
    )
    
    max_retries = 5
    for attempt in range(max_retries):
        try:
            with urllib.request.urlopen(req, timeout=40) as response:
                res = json.loads(response.read().decode('utf-8'))
                content = res['candidates'][0]['content']['parts'][0]['text']
                return json.loads(content)
        except Exception as e:
            status_code = getattr(e, 'code', None)
            print(f"Attempt {attempt+1} failed: {e}. Status: {status_code}", flush=True)
            if status_code == 429:
                wait_time = 15 * (attempt + 1)
                print(f"Rate limited (429). Retrying in {wait_time}s...", flush=True)
                time.sleep(wait_time)
            elif status_code == 503:
                wait_time = 10 * (attempt + 1)
                print(f"Service unavailable (503). Retrying in {wait_time}s...", flush=True)
                time.sleep(wait_time)
            else:
                time.sleep(5)
                
    raise Exception("Failed all attempts to call Gemini API.")

def main():
    if not DB_PATH.exists():
        print(f"❌ Error: Database file not found at {DB_PATH}", flush=True)
        return

    print(f"Loading database from {DB_PATH}...", flush=True)
    with open(DB_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f"Loaded {len(data)} records.", flush=True)
    
    bad_terms = ['मंजिल होती है', 'दाग नहीं छोड़ता', 'झरने लाऊंगी', 'राजा-रेणुका']
    
    # Identify items needing translation
    to_beautify = []
    for item in data:
        item_id = item.get('id')
        sanskrit = (item.get('sanskrit_text') or '').strip()
        hindi = (item.get('hindi_text') or '').strip()
        
        if not sanskrit:
            continue
            
        needs_beautify = False
        if not hindi:
            needs_beautify = True
        elif any(t in hindi for t in bad_terms):
            needs_beautify = True
        elif re.search(r'[a-zA-Z]{4,}', hindi):
            needs_beautify = True
            
        if needs_beautify:
            to_beautify.append({
                'id': item_id,
                'sanskrit_text': sanskrit
            })
            
    total_to_process = len(to_beautify)
    print(f"Total problematic/missing items needing translation: {total_to_process}", flush=True)
    
    if total_to_process == 0:
        print("🎉 All items are already beautiful and copyright-compliant!", flush=True)
        return
        
    # Process in batches of 18
    batch_size = 18
    processed = 0
    
    # Load cache if exists
    cache = {}
    if CACHE_PATH.exists():
        try:
            with open(CACHE_PATH, 'r', encoding='utf-8') as f:
                cache = json.load(f)
            print(f"Loaded cache with {len(cache)} items.", flush=True)
        except Exception as e:
            print(f"Warning: Could not load cache: {e}", flush=True)

    # Filter items that are already in cache
    items_to_run = [item for item in to_beautify if item['id'] not in cache]
    print(f"Remaining items to process (after cache check): {len(items_to_run)}", flush=True)
    
    if len(items_to_run) > 0:
        for i in range(0, len(items_to_run), batch_size):
            batch = items_to_run[i:i+batch_size]
            print(f"Processing batch {i//batch_size + 1}/{(len(items_to_run)-1)//batch_size + 1} (Size={len(batch)})...", flush=True)
            
            try:
                results = call_gemini_batch(batch)
                for res_item in results:
                    cache[res_item['id']] = res_item['hindi_text']
                processed += len(batch)
                
                # Save cache
                with open(CACHE_PATH, 'w', encoding='utf-8') as f:
                    json.dump(cache, f, ensure_ascii=False, indent=2)
                    
                print(f"Successfully processed {processed}/{len(items_to_run)} items in this run.", flush=True)
                
                # Sleep 40 seconds to comply with 20 RPM free limit
                if i + batch_size < len(items_to_run):
                    print("Sleeping 40 seconds to prevent rate limit...", flush=True)
                    time.sleep(40)
            except Exception as e:
                print(f"❌ Failed to process batch: {e}", flush=True)
                break

    # Merge cache back to main data
    print("Merging translations back into database...", flush=True)
    merge_count = 0
    for item in data:
        item_id = item.get('id')
        if item_id in cache:
            # Reconstruct clean Devanagari content_text
            item['hindi_text'] = cache[item_id]
            parts = []
            if item.get('sanskrit_text'):
                parts.append(item['sanskrit_text'])
            if item.get('author'):
                parts.append(f"- {item['author']}")
            parts.append(item['hindi_text'])
            item['content_text'] = "\n".join(parts)
            
            # Wiping copyrighted English fields for DMCA compliance
            item["english_text"] = ""
            item["english_translation"] = ""
            item["description"] = ""
            merge_count += 1
            
    with open(DB_PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Saved changes for {merge_count} items to {DB_PATH}.", flush=True)
    
    # Run post-sync scripts
    print("Running post-sync scripts to refresh frontend caches...", flush=True)
    try:
        subprocess.run(['node', 'frontend/scripts/sync_cache.mjs'], cwd=BASE_DIR, check=True)
        print("✅ Frontend cache refreshed.", flush=True)
    except Exception as e:
        print(f"❌ Failed to sync cache: {e}", flush=True)
        
    print("Uploading to Supabase...", flush=True)
    try:
        subprocess.run(['python3', 'backend/scripts/sync_to_supabase_clean.py'], cwd=BASE_DIR, check=True)
        print("✅ Supabase database refreshed.", flush=True)
    except Exception as e:
        print(f"❌ Failed to upload to Supabase: {e}", flush=True)
        
    print("🎉 Beautification process complete!", flush=True)

if __name__ == '__main__':
    main()
