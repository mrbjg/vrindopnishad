import os
import json
import re
import time
import urllib.request
import urllib.parse
from pathlib import Path

# Path configurations
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

API_CONFIGS = []
if env_key:
    API_CONFIGS.append({
        'key': env_key,
        'models': ['gemini-2.5-flash', 'gemini-2.0-flash']
    })

# Fallback configurations provided by user
fallbacks = [
    {
        'key': 'AQ.Ab8RN6ISfxlOzzqkxqjaXsseTIP6XVHKK2yTjCCfmVFpxvMyvQ',
        'models': ['gemini-2.5-flash', 'gemini-2.0-flash']
    },
    {
        'key': 'AQ.Ab8RN6Ize0y02udiUPBcyPt0noKd0G2EyWn8iPE8ttiTa1UpNg',
        'models': ['gemini-2.0-flash']
    }
]

for item in fallbacks:
    if not any(cfg['key'] == item['key'] for cfg in API_CONFIGS):
        API_CONFIGS.append(item)

def call_gemini_batch(items_batch):
    if not API_CONFIGS:
        raise Exception("No Gemini API keys found.")
        
    last_error = None
    
    for cfg in API_CONFIGS:
        key = cfg['key']
        for model in cfg['models']:
            url = f'https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={key}'
            
            prompt = f'''
You are an expert specializing in Vrindavan devotional literature and Vedic devotional texts.
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
                    with urllib.request.urlopen(req, timeout=30) as response:
                        res = json.loads(response.read().decode('utf-8'))
                        content = res['candidates'][0]['content']['parts'][0]['text']
                        return json.loads(content)
                except Exception as e:
                    error_msg = ""
                    if hasattr(e, 'read'):
                        try:
                            error_msg = e.read().decode('utf-8')
                        except:
                            pass
                    status_code = getattr(e, 'code', None)
                    print(f"Key {key[:8]}... model {model} attempt {attempt+1} failed: {e}. Detail: {error_msg[:100]}", flush=True)
                    last_error = e
                    
                    if status_code in (401, 403):
                        # Authorization error, skip key
                        break
                    elif status_code == 404:
                        # Model not found, skip model
                        break
                    elif status_code in (429, 503):
                        # Rate limit or service busy, sleep longer and retry
                        wait_time = 4 * (attempt + 1)
                        print(f"Transient code {status_code}. Retrying in {wait_time}s...", flush=True)
                        time.sleep(wait_time)
                        continue
                    else:
                        time.sleep(2)
                        continue
            continue
                
    raise Exception(f"Failed all key and model combinations. Last error: {last_error}")

def main():
    if not API_CONFIGS:
        print("❌ Error: No Gemini API keys configured.", flush=True)
        return

    if not DB_PATH.exists():
        print(f"❌ Error: Database file not found at {DB_PATH}", flush=True)
        return
        
    print(f"Loading database from {DB_PATH}...", flush=True)
    with open(DB_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f"Loaded {len(data)} records.", flush=True)
    
    # Load HEAD data for comparison
    print("Loading HEAD content for machine translation filtering...", flush=True)
    import subprocess
    head_by_id = {}
    try:
        head_content = subprocess.check_output(['git', 'show', 'HEAD:frontend/data/vrindavaani_content.json'], stderr=subprocess.DEVNULL)
        head_data = json.loads(head_content.decode('utf-8'))
        head_by_id = {x['id']: x for x in head_data if 'id' in x}
        print(f"Loaded {len(head_by_id)} records from HEAD.", flush=True)
    except Exception as e:
        print(f"⚠️ Warning: Could not read HEAD database: {e}. Falling back to basic filtering.", flush=True)
    
    # Load cache if exists
    cache = {}
    if CACHE_PATH.exists():
        with open(CACHE_PATH, 'r', encoding='utf-8') as f:
            cache = json.load(f)
        print(f"Loaded cache with {len(cache)} already beautified items.", flush=True)
        
    # Identify items that need beautifying
    to_beautify = []
    for item in data:
        item_id = item.get('id')
        if not item_id or item_id in cache:
            continue
            
        sanskrit = (item.get('sanskrit_text') or '').strip()
        hindi = (item.get('hindi_text') or '').strip()
        
        if not sanskrit:
            continue
            
        needs_beautify = False
        # 1. Hindi text is completely empty
        if not hindi:
            needs_beautify = True
        # 2. Hindi text is populated now, but in HEAD it was empty (reverted/machine-translated)
        elif item_id in head_by_id and not head_by_id[item_id].get('hindi_text'):
            needs_beautify = True
        # 3. Explicit machine-translation terms detection
        elif 'मंजिल होती है' in hindi or 'दाग नहीं छोड़ता' in hindi or 'झरने लाऊंगी' in hindi or 'राजा-रेणुका' in hindi:
            needs_beautify = True
        elif re.search(r'[a-zA-Z]{4,}', hindi):
            needs_beautify = True
            
        if needs_beautify:
            to_beautify.append({
                'id': item_id,
                'sanskrit_text': sanskrit
            })
            
    total_to_process = len(to_beautify)
    print(f"Total items needing beautification: {total_to_process}", flush=True)
    
    if total_to_process == 0:
        print("🎉 No items need beautification!", flush=True)
    else:
        # Process in batches of 5 (stable size to prevent model timeout and rate-limit hits)
        batch_size = 5
        processed = 0
        
        for i in range(0, total_to_process, batch_size):
            batch = to_beautify[i:i+batch_size]
            print(f"Processing batch {i//batch_size + 1}/{(total_to_process-1)//batch_size + 1} (Size={len(batch)})...", flush=True)
            
            try:
                results = call_gemini_batch(batch)
                for res_item in results:
                    cache[res_item['id']] = res_item['hindi_text']
                processed += len(batch)
                
                # Save cache periodically
                with open(CACHE_PATH, 'w', encoding='utf-8') as f:
                    json.dump(cache, f, ensure_ascii=False, indent=2)
                    
                print(f"Successfully processed {processed}/{total_to_process} items.", flush=True)
                # Rate limit is 15 requests per minute, so sleep 5.0 seconds between batches
                time.sleep(5.0)
            except Exception as e:
                print(f"❌ Failed to process batch: {e}", flush=True)
                break
            
    # Merge cache back to data
    print("Merging beautified translations back into database...", flush=True)
    merge_count = 0
    for item in data:
        item_id = item.get('id')
        if item_id in cache:
            # Update hindi_text
            item['hindi_text'] = cache[item_id]
            # Update content_text
            parts = []
            if item.get("sanskrit_text"):
                parts.append(item["sanskrit_text"])
            if item.get("author"):
                parts.append(f"- {item['author']}")
            if cache[item_id]:
                parts.append(cache[item_id])
            item["content_text"] = "\n".join(parts)
            merge_count += 1
            
    print(f"Updated {merge_count} items in memory.", flush=True)
    
    # Save database
    with open(DB_PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Saved changes to {DB_PATH}", flush=True)
    
    # Clean cache if completed
    if total_to_process > 0 and processed == total_to_process:
        try:
            os.remove(CACHE_PATH)
            print("Removed temporary cache file.", flush=True)
        except Exception as e:
            pass
            
    # Run post-sync scripts
    print("Running post-sync scripts to refresh frontend caches...", flush=True)
    try:
        # 1. Regenerate frontend cache
        subprocess.run(['node', 'frontend/scripts/sync_cache.mjs'], cwd=BASE_DIR, check=True)
        # 2. Sync to Supabase
        subprocess.run(['python3', 'backend/scripts/sync_to_supabase_clean.py'], cwd=BASE_DIR, check=True)
        print("🎉 Frontend caches and Supabase database refreshed successfully!", flush=True)
    except Exception as e:
        print(f"❌ Warning: Failed to run post-sync scripts: {e}", flush=True)

    print("🎉 Beautification process complete!", flush=True)

if __name__ == '__main__':
    main()
