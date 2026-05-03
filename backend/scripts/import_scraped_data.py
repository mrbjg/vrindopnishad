import json
import urllib.request
import urllib.parse
from datetime import datetime, timezone
from pathlib import Path

def load_credentials():
    env_path = Path(__file__).parent.parent / ".env"
    creds = {}
    if env_path.exists():
        with open(env_path, 'r', encoding='utf-8') as f:
            for line in f:
                if '=' in line:
                    key, val = line.strip().split('=', 1)
                    creds[key] = val
    return creds

def supabase_bulk_upsert(url, key, table, batch_data):
    endpoint = f"{url}/rest/v1/{table}?on_conflict=slug"
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal,resolution=merge-duplicates"
    }
    
    clean_batch = []
    seen_slugs = set()
    
    # Final safety check for duplicates within the batch
    for data in batch_data:
        slug = data.get("slug")
        if not slug or slug in seen_slugs: continue
        
        seen_slugs.add(slug)
        clean_batch.append({
            "title": data.get("title"),
            "sanskrit_text": data.get("sanskrit_text"),
            "hindi_text": data.get("hindi_text"),
            "english_translation": data.get("english_translation"),
            "category": data.get("category"),
            "slug": slug,
            "author": data.get("author", "Braj Rasik Heritage"),
            "image_url": data.get("image_url"),
            "audio_url": data.get("audio_url"),
            "status": "published",
            "updated_at": datetime.now(timezone.utc).isoformat()
        })
    
    if not clean_batch: return True
    
    json_data = json.dumps(clean_batch).encode('utf-8')
    req = urllib.request.Request(endpoint, data=json_data, headers=headers, method='POST')
    
    try:
        with urllib.request.urlopen(req) as response:
            return True
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        print(f"❌ Supabase Error: {error_body}")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("--- Braj Rasik DEDUPLICATED MASTER 11.0 ---")
    creds = load_credentials()
    url = creds.get('SUPABASE_URL')
    key = creds.get('SUPABASE_ANON_KEY')
    
    if not url or not key:
        print("❌ Error: Supabase credentials missing in .env")
        return

    json_path = Path(__file__).parent / "scraped_data.json"
    if not json_path.exists():
        print(f"❌ Error: {json_path} not found.")
        return

    with open(json_path, 'r', encoding='utf-8') as f:
        raw_data = json.load(f)

    # DEDUPLICATION LOGIC
    print(f"Initial items: {len(raw_data)}. Removing duplicates...")
    dedup_map = {}
    for item in raw_data:
        slug = item.get('slug')
        if slug:
            dedup_map[slug] = item
    
    data = list(dedup_map.values())
    print(f"Clean items for sync: {len(data)}")

    batch_size = 200
    total_items = len(data)
    
    success_count = 0
    for i in range(0, total_items, batch_size):
        batch = data[i:i + batch_size]
        print(f"🚀 Syncing unique batch {i//batch_size + 1}/{(total_items // batch_size) + 1}...")
        if supabase_bulk_upsert(url, key, "content", batch):
            success_count += len(batch)
        else:
            print(f"🛑 Batch {i//batch_size + 1} failed.")

    print(f"--- Final Deduplicated Sync Result ---")
    print(f"✅ Successfully synced: {success_count} unique records.")

if __name__ == "__main__":
    main()
