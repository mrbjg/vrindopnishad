import os
import json
import uuid
import logging
import sys
from pathlib import Path
from datetime import datetime, timezone

# Add parent directory to sys.path to find supabase_client
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from supabase_client import SupabaseDB
from dotenv import load_dotenv

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment
ROOT_DIR = Path(__file__).parent.parent
load_dotenv(ROOT_DIR / '.env')

def migrate_json_files(db, json_dir):
    if not os.path.exists(json_dir):
        logger.error(f"JSON directory not found: {json_dir}")
        return

    json_files = [f for f in os.listdir(json_dir) if f.endswith('.json')]
    
    for filename in json_files:
        file_path = os.path.join(json_dir, filename)
        logger.info(f"Processing {filename}...")
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            # Identify format
            if 'collection' in data and 'entries' in data['collection']:
                # Standard Vrindopnishad Web format
                entries = data['collection']['entries']
                for entry in entries:
                    migrate_entry(db, entry)
            elif 'blocks' in data:
                # audio-data.json format
                for section_name, section_data in data['blocks'].items():
                    migrate_block(db, section_data, "Audio Block")
            elif 'additionalTracks' in data:
                 for track in data['additionalTracks']:
                    migrate_block(db, track, "Audio Track")
            else:
                logger.warning(f"Unknown format in {filename}")
                
        except Exception as e:
            logger.error(f"Error processing {filename}: {e}")

def migrate_entry(db, entry):
    content_id = entry.get('id', str(uuid.uuid4()))
    # Ensure it's a valid UUID if that's what the DB expects, but postgres handles strings as well if typed correctly.
    # The JSON ids are like 'entry-123-abc'. Supabase schema says UUID PRIMARY KEY.
    # I might need to generate fresh UUIDs if I want to stick to the schema, or change schema to TEXT.
    # Let's try to generate one from the string to be consistent if possible, otherwise use a fresh one.
    
    try:
        # Try to use existing ID if it's a UUID string
        u_id = str(uuid.UUID(content_id))
    except:
        u_id = str(uuid.uuid4())

    content_data = {
        "id": u_id,
        "title": entry.get('title', 'Untitled'),
        "description": entry.get('description', ''),
        "category": entry.get('category', 'General'),
        "tags": entry.get('tags', []),
        "status": "published",
        "created_at": entry.get('created', datetime.now(timezone.utc).isoformat()),
        "updated_at": entry.get('modified', datetime.now(timezone.utc).isoformat()),
    }
    
    # Handle nested content
    inner_content = entry.get('content', {})
    if inner_content:
        content_data["content_text"] = inner_content.get('content', '')
        content_data["status"] = inner_content.get('status', 'published')
        if not content_data["description"]:
            content_data["description"] = inner_content.get('excerpt', '')
        # Merge tags
        tags = set(content_data["tags"])
        tags.update(inner_content.get('tags', []))
        content_data["tags"] = list(tags)

    # Media links
    media_links = []
    for img in entry.get('images', []):
        media_links.append({"type": "image", "url": img.get('url'), "title": img.get('title')})
    for vid in entry.get('videos', []):
        media_links.append({"type": vid.get('type', 'video'), "url": vid.get('url'), "title": vid.get('title')})
    for aud in entry.get('audios', []):
        media_links.append({"type": "audio", "url": aud.get('url'), "title": aud.get('title')})
    for link in entry.get('links', []):
        media_links.append({"type": "link", "url": link.get('url'), "title": link.get('title')})
    
    content_data["media_links"] = media_links
    
    # Extract legacy image_urls, audio_url, video_urls if list is available
    content_data["image_urls"] = [m['url'] for m in media_links if m['type'] == 'image']
    content_data["video_urls"] = [m['url'] for m in media_links if m['type'] == 'video']
    audio_links = [m['url'] for m in media_links if m['type'] == 'audio']
    content_data["audio_url"] = audio_links[0] if audio_links else None

    # Upload to Supabase
    try:
        db.client.table(db.table_name).upsert(content_data).execute()
        logger.info(f"Migrated entry: {content_data['title']}")
    except Exception as e:
        logger.error(f"Failed to migrate {content_data['title']}: {e}")

def migrate_block(db, block, default_category):
    content_id = block.get('id', str(uuid.uuid4()))
    try:
        u_id = str(uuid.UUID(content_id))
    except:
        u_id = str(uuid.uuid4())
        
    content_data = {
        "id": u_id,
        "title": block.get('title', 'Untitled'),
        "description": block.get('description', ''),
        "category": block.get('category', default_category),
        "tags": [],
        "status": "published",
        "content_text": "",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "updated_at": datetime.now(timezone.utc).isoformat(),
        "media_links": [],
        "image_urls": [],
        "video_urls": []
    }
    
    if 'audioSrc' in block:
        content_data["audio_url"] = block['audioSrc']
        content_data["media_links"].append({"type": "audio", "url": block['audioSrc'], "title": "Audio Track"})
    else:
        content_data["audio_url"] = None
        
    # Upload to Supabase
    try:
        db.client.table(db.table_name).upsert(content_data).execute()
        logger.info(f"Migrated block/track: {content_data['title']}")
    except Exception as e:
        logger.error(f"Failed to migrate block {content_data['title']}: {e}")

if __name__ == "__main__":
    db = SupabaseDB()
    if db.is_available:
        json_dir = "/Users/mr.bajrangi/Code/Company/Vrindopnishad Web/class/json"
        migrate_json_files(db, json_dir)
        logger.info("Migration complete!")
    else:
        logger.error("Failed to initialize Supabase database")
