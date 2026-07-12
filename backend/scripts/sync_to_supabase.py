import os
import json
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client

SCRIPT_DIR = Path(__file__).parent
BACKEND_DIR = SCRIPT_DIR.parent
load_dotenv(BACKEND_DIR / '.env')

# Supabase Client Setup
url = os.environ.get('SUPABASE_URL', '')
key = os.environ.get('SUPABASE_SERVICE_ROLE_KEY') or os.environ.get('SUPABASE_ANON_KEY', '')
if not url or not key:
    print("Error: Supabase environment variables (SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY) are missing.")
    exit(1)

supabase_client = create_client(url, key)

def main():
    db_path = BACKEND_DIR.parent / 'frontend/data/vrindavaani_content.json'
    if not db_path.exists():
        print(f"Error: Local database file not found at {db_path}")
        return
        
    print(f"Loading local database from {db_path}...")
    with open(db_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f"Loaded {len(data)} records.")
    
    # Prepare records for Supabase schema
    updated_supabase_records = []
    for item in data:
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
        
    print(f"Uploading {len(updated_supabase_records)} records to Supabase content table...")
    batch_upload_size = 100
    uploaded_count = 0
    for i in range(0, len(updated_supabase_records), batch_upload_size):
        batch = updated_supabase_records[i:i+batch_upload_size]
        try:
            supabase_client.table('content').upsert(batch).execute()
            uploaded_count += len(batch)
            if uploaded_count % 500 == 0 or uploaded_count == len(updated_supabase_records):
                print(f"Supabase progress: {uploaded_count}/{len(updated_supabase_records)} uploaded.")
        except Exception as e:
            print(f"❌ Failed to upsert batch starting at {i}: {e}")
            
    print("🎉 Sync to Supabase complete!")

if __name__ == '__main__':
    main()
