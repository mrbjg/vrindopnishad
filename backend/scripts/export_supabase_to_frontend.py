import os
import json
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client

ROOT_DIR = Path(__file__).parent.parent
load_dotenv(ROOT_DIR / '.env')

url = os.environ.get('SUPABASE_URL', '')
key = os.environ.get('SUPABASE_SERVICE_ROLE_KEY') or os.environ.get('SUPABASE_ANON_KEY', '')

client = create_client(url, key)

def classify_item_category(item):
    # Match the JS helper logic
    cat = item.get('category', 'poem')
    if cat in ['shloka', 'strotra', 'poem', 'saint', 'dham']:
        return cat
    return 'poem'

def export_all():
    print("🚀 Fetching all content from Supabase...")
    all_items = []
    limit = 1000
    start = 0

    while True:
        print(f"Fetching range {start} to {start + limit - 1}...")
        res = client.table('content').select('*').range(start, start + limit - 1).execute()
        data = res.data or []
        all_items.extend(data)
        print(f"Fetched {len(data)} items. Total: {len(all_items)}")
        if len(data) < limit:
            break
        start += limit

    print(f"🎉 Successfully fetched {len(all_items)} records from Supabase.")

    # Map items to exact frontend schema
    mapped = []
    for item in all_items:
        mapped.append({
            "id": item.get("id", ""),
            "title": item.get("title", ""),
            "sanskrit_text": item.get("sanskrit_text", "") or "",
            "hindi_text": item.get("hindi_text", "") or "",
            "english_text": item.get("english_text", "") or "",
            "english_translation": item.get("english_translation", "") or "",
            "category": item.get("category", "poem"),
            "description": item.get("description", "") or "",
            "content_text": item.get("content_text", "") or "",
            "tags": item.get("tags", []) or [],
            "status": item.get("status", "published"),
            "author": item.get("author", "Braj Rasik Heritage"),
            "media_links": item.get("media_links", []) or [],
            "audio_url": item.get("audio_url", "") or "",
            "image_urls": item.get("image_urls", []) or [],
            "video_urls": item.get("video_urls", []) or [],
            "slug": item.get("slug", ""),
            "created_at": item.get("created_at", ""),
            "updated_at": item.get("updated_at", "")
        })

    # Save directories
    frontend_dir = ROOT_DIR.parent / 'frontend'
    data_dir = frontend_dir / 'data'
    public_data_dir = frontend_dir / 'public/data'

    os.makedirs(data_dir, exist_ok=True)
    os.makedirs(public_data_dir, exist_ok=True)

    # 1. Write the main local hi_full file
    target_path = data_dir / 'brajrasik_hi_full.json'
    with open(target_path, 'w', encoding='utf-8') as f:
        json.dump(mapped, f, ensure_ascii=False, indent=2)
    print(f"💾 Saved {len(mapped)} mapped items to {target_path}")

    # 2. Write the processed_cache.json file used by contentData.js
    saints_path = data_dir / 'saints_formatted.json'
    raw_saints = []
    if os.path.exists(saints_path):
        try:
            with open(saints_path, 'r', encoding='utf-8') as f:
                raw_saints = json.load(f)
        except Exception as e:
            print(f"⚠️ Failed to parse saints_formatted.json: {e}")

    processed_cache_path = data_dir / 'processed_cache.json'
    with open(processed_cache_path, 'w', encoding='utf-8') as f:
        json.dump({
            "verses": mapped,
            "saintsRaw": raw_saints
        }, f, ensure_ascii=False, indent=2)
    print(f"💾 Saved flat cache to {processed_cache_path}")

    # 3. Write public/data backup files
    backup_file = public_data_dir / 'content_backup.json'
    with open(backup_file, 'w', encoding='utf-8') as f:
        json.dump(mapped, f, ensure_ascii=False, indent=2)
    print(f"💾 Saved backup to {backup_file}")

    # 4. Split and write category-specific files
    categories = ['shloka', 'strotra', 'poem', 'saint', 'dham']
    for cat in categories:
        cat_file = public_data_dir / f"content_backup_{cat}.json"
        cat_verses = []
        if cat == 'saint':
            cat_verses = [{
                "id": s.get("id", f"saint-local-{idx}"),
                "category": "saint",
                **s
            } for idx, s in enumerate(raw_saints)]
        else:
            cat_verses = [v for v in mapped if classify_item_category(v) == cat]
            
        with open(cat_file, 'w', encoding='utf-8') as f:
            json.dump(cat_verses, f, ensure_ascii=False, indent=2)
        print(f"💾 Saved category split ({cat}) with {len(cat_verses)} items to {cat_file}")

if __name__ == '__main__':
    export_all()
