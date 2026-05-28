import os
import json
import uuid
import logging
import sys
import re
from pathlib import Path
from datetime import datetime, timezone
import dateutil.parser

# Add parent directory to sys.path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from supabase_client import get_supabase_client
from dotenv import load_dotenv

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

ROOT_DIR = Path(__file__).parent.parent
load_dotenv(ROOT_DIR / '.env')
OUT_DIR = Path(__file__).parent

client = get_supabase_client()

def clean_html(raw_html):
    if not raw_html: return ""
    # Preserve line breaks for verses
    text = raw_html.replace('<br>', '\n').replace('<br/>', '\n').replace('</div>', '\n').replace('</p>', '\n')
    cleanr = re.compile('<script.*?>.*?</script>|<style.*?>.*?</style>', re.DOTALL)
    text = re.sub(cleanr, '', text)
    cleanr = re.compile('<.*?>')
    text = re.sub(cleanr, '', text)
    # Fix HTML entities
    text = text.replace('&nbsp;', ' ').replace('&amp;', '&').replace('&quot;', '"')
    return text.strip()

def classify_category(title, sanskrit, raw_cat):
    raw_cat_lower = raw_cat.lower().strip()
    if raw_cat_lower in ['saint', 'dham']:
        return raw_cat_lower
        
    title_lower = title.lower()
    sanskrit_lower = sanskrit.lower()
    
    if 'स्तोत्र' in title_lower or 'strotra' in title_lower or 'stotra' in title_lower or 'शतक' in title_lower or 'shatak' in title_lower or 'अष्टक' in title_lower or 'ashtak' in title_lower:
        return 'strotra'
        
    if '॥' in sanskrit_lower or 'ॐ' in sanskrit_lower or 'गीता' in title_lower or 'gita' in title_lower:
        return 'shloka'
        
    return 'poem'

def format_date(date_str):
    if not date_str:
        return datetime.now(timezone.utc).isoformat()
    try:
        clean_str = str(date_str)
        if "(" in clean_str:
            clean_str = clean_str.split("(")[0].strip()
        return dateutil.parser.parse(clean_str).isoformat()
    except Exception as e:
        logger.warning(f"Failed to parse date string '{date_str}': {e}")
        return datetime.now(timezone.utc).isoformat()

def merge_records(db_record, scraped_record):
    merged = dict(db_record) # start with database values
    
    for key, scrap_val in scraped_record.items():
        db_val = db_record.get(key)
        
        # 1. If database value is null/None/empty, fill it
        if db_val is None or db_val == "" or db_val == [] or db_val == {} or db_val == 0:
            if scrap_val is not None and scrap_val != "" and scrap_val != [] and scrap_val != {} and scrap_val != 0:
                merged[key] = scrap_val
        # 2. If both are lists/arrays, merge them (union)
        elif isinstance(db_val, list) and isinstance(scrap_val, list):
            # Combine lists and remove duplicates
            merged[key] = list(set(db_val).union(set(scrap_val)))
        # 3. If both are dicts, merge keys
        elif isinstance(db_val, dict) and isinstance(scrap_val, dict):
            merged[key] = {**scrap_val, **db_val} # database keys take precedence, but new keys are added
            
    return merged

def check_table_exists(table_name):
    try:
        # A simple query to check if table is available
        client.table(table_name).select("count", count="exact").limit(1).execute()
        return True
    except Exception as e:
        logger.warning(f"Table '{table_name}' does not appear to exist. Error: {e}")
        return False

def sync_table_in_batches(table_name, primary_key_col, raw_items, mapper_func, batch_size=100):
    logger.info(f"Syncing table '{table_name}'...")
    if not check_table_exists(table_name):
        logger.error(f"❌ Aborting sync for '{table_name}' because it does not exist in Supabase. Please run the DDL schema first!")
        return {}
        
    mapped_items = [mapper_func(item) for item in raw_items]
    
    # Remove duplicates from mapped items by primary key
    unique_map = {}
    for item in mapped_items:
        pk_val = item.get(primary_key_col)
        if pk_val:
            unique_map[pk_val] = item
    mapped_items = list(unique_map.values())
    
    total = len(mapped_items)
    success_count = 0
    
    for i in range(0, total, batch_size):
        batch = mapped_items[i:i+batch_size]
        batch_ids = [item[primary_key_col] for item in batch]
        
        # 1. Fetch existing items in this batch from Supabase
        existing_map = {}
        try:
            res = client.table(table_name).select('*').in_(primary_key_col, batch_ids).execute()
            existing_map = {row[primary_key_col]: row for row in res.data}
        except Exception as e:
            logger.warning(f"Fetch failed for batch in '{table_name}', performing default upsert. Error: {e}")
            
        # 2. Merge scraped items with existing items
        upsert_batch = []
        for item in batch:
            pk_val = item[primary_key_col]
            if pk_val in existing_map:
                merged_item = merge_records(existing_map[pk_val], item)
                upsert_batch.append(merged_item)
            else:
                upsert_batch.append(item)
                
        # 3. Perform bulk upsert
        try:
            client.table(table_name).upsert(upsert_batch).execute()
            success_count += len(upsert_batch)
        except Exception as e:
            logger.error(f"❌ Bulk upsert failed for batch in '{table_name}': {e}")
            
    logger.info(f"✅ Finished syncing '{table_name}': {success_count}/{total} records.")
    return {item[primary_key_col]: item for item in mapped_items}

# Mappers
def map_tag(raw):
    return {
        "tag_id": raw.get("tag_id"),
        "_id": raw.get("_id"),
        "name": raw.get("name", ""),
        "name_hindi": raw.get("nameHindi"),
        "info": raw.get("info"),
        "info_hindi": raw.get("infoHindi"),
        "type": raw.get("type", "general"),
        "active": raw.get("active", True),
        "priority": str(raw.get("priority")) if raw.get("priority") is not None else None,
        "facebook_id": raw.get("facebook_id"),
        "biography_id": raw.get("biography_id"),
        "book_linked_id": raw.get("book_linked_id"),
        "chapter_name_eng": raw.get("chapter_name_eng"),
        "chapter_name_hindi": raw.get("chapter_name_hindi"),
        "chapter_no": str(raw.get("chapter_no")) if raw.get("chapter_no") is not None else None,
        "saint_linked_id": raw.get("saint_linked_id"),
        "lang": raw.get("lang"),
        "total_verses": str(raw.get("total_verses")) if raw.get("total_verses") is not None else None,
        "photos": raw.get("photos", []),
        "created_at": format_date(raw.get("createdAt")),
        "updated_at": format_date(raw.get("updatedAt"))
    }

def map_place(raw):
    return {
        "place_id": raw.get("place_id"),
        "_id": raw.get("_id"),
        "name": raw.get("name", ""),
        "name_hindi": raw.get("nameHindi"),
        "info": raw.get("info"),
        "info_hindi": raw.get("infoHindi"),
        "active": raw.get("active", True),
        "priority": str(raw.get("priority")) if raw.get("priority") is not None else None,
        "facebook_id": raw.get("facebook_id"),
        "path": raw.get("path"),
        "type": raw.get("type"),
        "latitude": raw.get("latitude"),
        "longitude": raw.get("longitude"),
        "videos": raw.get("videos", []),
        "created_at": format_date(raw.get("createdAt")),
        "updated_at": format_date(raw.get("updatedAt"))
    }

def map_album(raw):
    return {
        "album_id": raw.get("album_id"),
        "_id": raw.get("_id"),
        "name": raw.get("name", ""),
        "name_hindi": raw.get("nameHindi"),
        "info": raw.get("info"),
        "info_hindi": raw.get("infoHindi"),
        "active": raw.get("active", True),
        "priority": str(raw.get("priority")) if raw.get("priority") is not None else None,
        "facebook_id": raw.get("facebook_id"),
        "path": raw.get("path"),
        "type": raw.get("type"),
        "places": raw.get("places", []),
        "videos": raw.get("videos", []),
        "created_at": format_date(raw.get("createdAt")),
        "updated_at": format_date(raw.get("updatedAt"))
    }

def map_raag(raw):
    return {
        "raag_id": raw.get("raag_id"),
        "_id": raw.get("_id"),
        "name": raw.get("name", ""),
        "name_hindi": raw.get("nameHindi"),
        "info": raw.get("info"),
        "info_hindi": raw.get("infoHindi"),
        "active": raw.get("active", True),
        "priority": str(raw.get("priority")) if raw.get("priority") is not None else None,
        "facebook_id": raw.get("facebook_id"),
        "type": raw.get("type"),
        "created_at": format_date(raw.get("createdAt")),
        "updated_at": format_date(raw.get("updatedAt"))
    }

def map_subject(raw):
    return {
        "subject_id": raw.get("subject_id"),
        "_id": raw.get("_id"),
        "name": raw.get("name", ""),
        "name_hindi": raw.get("nameHindi"),
        "info": raw.get("info"),
        "info_hindi": raw.get("infoHindi"),
        "active": raw.get("active", True),
        "priority": str(raw.get("priority")) if raw.get("priority") is not None else None,
        "facebook_id": raw.get("facebook_id"),
        "type": raw.get("type"),
        "created_at": format_date(raw.get("createdAt")),
        "updated_at": format_date(raw.get("updatedAt"))
    }

def map_glossary(raw):
    return {
        "glossary_id": raw.get("glossary_id"),
        "_id": raw.get("_id"),
        "name": raw.get("name", ""),
        "name_hindi": raw.get("nameHindi"),
        "info": raw.get("info"),
        "info_hindi": raw.get("infoHindi"),
        "active": raw.get("active", True),
        "priority": str(raw.get("priority")) if raw.get("priority") is not None else None,
        "facebook_id": raw.get("facebook_id"),
        "type": raw.get("type"),
        "created_at": format_date(raw.get("createdAt")),
        "updated_at": format_date(raw.get("updatedAt"))
    }

def map_media(raw):
    return {
        "media_id": raw.get("_id"),
        "album_id": raw.get("album_id"),
        "name": raw.get("name"),
        "name_hindi": raw.get("nameHindi"),
        "priority": str(raw.get("priority")) if raw.get("priority") is not None else None,
        "active": raw.get("active", True),
        "created_at": format_date(raw.get("createdAt")),
        "updated_at": format_date(raw.get("updatedAt"))
    }

def main():
    if not client:
        logger.error("Supabase client not initialized. Check your credentials.")
        return
        
    logger.info("Starting BrajRasik Relational Supabase Sync...")
    
    # Pre-build mappings for relations
    album_to_medias = {}
    medias_file = OUT_DIR / "medias_raw.json"
    if medias_file.exists():
        try:
            with open(medias_file, 'r', encoding='utf-8') as f:
                medias_data = json.load(f)
            for m in medias_data:
                a_id = m.get("album_id")
                m_id = m.get("_id")
                if a_id and m_id:
                    album_to_medias.setdefault(a_id, []).append(m_id)
        except Exception as e:
            logger.error(f"Failed to build album_to_medias map: {e}")

    album_to_places = {}
    albums_file = OUT_DIR / "albums_raw.json"
    if albums_file.exists():
        try:
            with open(albums_file, 'r', encoding='utf-8') as f:
                albums_data = json.load(f)
            for alb in albums_data:
                alb_id = alb.get("album_id")
                places_list = alb.get("places", [])
                if alb_id and places_list:
                    album_to_places[alb_id] = places_list
        except Exception as e:
            logger.error(f"Failed to build album_to_places map: {e}")

    # 1. Sync metadata lookups
    metadata_files = {
        "tags": ("tags_raw.json", "tag_id", map_tag),
        "places": ("places_raw.json", "place_id", map_place),
        "albums": ("albums_raw.json", "album_id", map_album),
        "raags": ("raags_raw.json", "raag_id", map_raag),
        "subjects": ("subjects_raw.json", "subject_id", map_subject),
        "glossarys": ("glossarys_raw.json", "glossary_id", map_glossary),
        "medias": ("medias_raw.json", "media_id", map_media)
    }
    
    synced_lookups = {}
    
    for table_name, (filename, pk, mapper) in metadata_files.items():
        filepath = OUT_DIR / filename
        if not filepath.exists():
            logger.warning(f"Skipping lookup table '{table_name}': file {filename} not found.")
            continue
            
        with open(filepath, 'r', encoding='utf-8') as f:
            raw_data = json.load(f)
            
        if table_name == "tags":
            # Pass 1: Set saint_linked_id to None to avoid foreign key violations
            def map_tag_no_fk(raw):
                mapped = mapper(raw)
                mapped["saint_linked_id"] = None
                return mapped
            
            synced_lookups[table_name] = sync_table_in_batches(table_name, pk, raw_data, map_tag_no_fk)
            
            # Pass 2: Link saint_linked_id
            logger.info("Performing second pass for 'tags' to link saint_linked_id...")
            fk_updates = []
            valid_tag_ids = set(synced_lookups[table_name].keys())
            for raw_item in raw_data:
                tag_id = raw_item.get("tag_id")
                saint_id = raw_item.get("saint_linked_id")
                if tag_id and saint_id:
                    if saint_id in valid_tag_ids:
                        fk_updates.append({"tag_id": tag_id, "saint_linked_id": saint_id})
                    else:
                        logger.warning(f"Tag '{tag_id}' references saint '{saint_id}' which does not exist in tags_raw.json.")
            
            if fk_updates:
                logger.info(f"Upserting {len(fk_updates)} saint relationships for tags...")
                for k in range(0, len(fk_updates), 100):
                    batch = fk_updates[k:k+100]
                    try:
                        client.table("tags").upsert(batch).execute()
                    except Exception as e:
                        logger.error(f"❌ Failed to upsert saint_linked_id updates for tags: {e}")
        else:
            synced_lookups[table_name] = sync_table_in_batches(table_name, pk, raw_data, mapper)
        
    # 2. Sync main articles table (maps to 'content' table)
    articles_file = OUT_DIR / "articles_raw.json"
    if not articles_file.exists():
        logger.error("❌ articles_raw.json not found! Cannot sync main articles content.")
        return
        
    with open(articles_file, 'r', encoding='utf-8') as f:
        raw_articles = json.load(f)
        
    logger.info(f"Syncing articles (content table) - {len(raw_articles)} items...")
    
    # Deduplicate in-memory by slug (url)
    dedup_articles = {}
    for art in raw_articles:
        slug = art.get('url')
        if slug:
            dedup_articles[slug] = art
    articles_list = list(dedup_articles.values())
    
    total_articles = len(articles_list)
    articles_success = 0
    batch_size = 100
    
    # Store article slug -> UUID mapping to resolve foreign keys for junctions
    article_slug_to_id = {}
    
    # Track junction relations to insert
    junction_tags = []
    junction_places = []
    junction_raags = []
    junction_subjects = []
    junction_medias = []
    
    for i in range(0, total_articles, batch_size):
        batch = articles_list[i:i+batch_size]
        batch_slugs = [art.get('url') for art in batch if art.get('url')]
        
        # Query existing by slug
        existing_map = {}
        try:
            res = client.table('content').select('*').in_('slug', batch_slugs).execute()
            existing_map = {row['slug']: row for row in res.data}
        except Exception as e:
            logger.warning(f"Failed to fetch existing content batch: {e}")
            
        upsert_batch = []
        for raw_art in batch:
            slug = raw_art.get('url')
            existing_row = existing_map.get(slug)
            
            existing_id = existing_row.get('id') if existing_row else None
            
            # Map scraped to content columns
            mapped_art = {
                "title": clean_html(raw_art.get('translation', [{}])[0].get('title', slug)),
                "sanskrit_text": "",
                "hindi_text": "",
                "english_text": "",
                "english_translation": "",
                "category": "poem",
                "description": clean_html(raw_art.get('description', ''))[:500],
                "audio_url": raw_art.get('audio'),
                "image_urls": [],
                "video_urls": [],
                "created_at": format_date(raw_art.get("createdAt")),
                "updated_at": format_date(raw_art.get("updatedAt")),
                "tags": [],
                "status": "published",
                "author": 'Braj Rasik Heritage',
                "slug": slug,
                "image_url": raw_art.get('image'),
                "commentary": ""
            }
            
            # Parse translation arrays
            translations = raw_art.get('translation', [])
            eng_obj = translations[0] if len(translations) > 0 else {}
            native_obj = translations[1] if len(translations) > 1 else (translations[0] if len(translations) == 1 else {})
            
            title = native_obj.get('title') or eng_obj.get('title') or slug
            native_content = clean_html(native_obj.get('detail', ''))
            eng_content = clean_html(eng_obj.get('detail', ''))
            
            mapped_art["title"] = title
            mapped_art["hindi_text"] = native_content
            mapped_art["english_translation"] = eng_content if eng_content != native_content else ""
            mapped_art["english_text"] = eng_content if eng_content != native_content else ""
            
            # Extract Sanskrit vs Hindi
            sanskrit_text = ""
            hindi_text = native_content
            root_lang = raw_art.get('lang', 'hindi')
            if root_lang == "sanskrit" or "॥" in native_content:
                parts = native_content.split('\n\n', 1)
                if len(parts) > 1:
                    sanskrit_text = parts[0]
                    hindi_text = parts[1]
                else:
                    sanskrit_text = native_content
            
            mapped_art["sanskrit_text"] = sanskrit_text
            mapped_art["hindi_text"] = hindi_text
            
            # Classify category
            raw_cat = "general"
            if 'sankirtan' in slug: raw_cat = "sankirtan"
            elif 'saint' in slug: raw_cat = "saint"
            elif 'dham' in slug: raw_cat = "dham"
            elif 'literature' in slug: raw_cat = "literature"
            
            mapped_art["category"] = classify_category(title, sanskrit_text, raw_cat)
            
            # Author mapping
            author_obj = raw_art.get('author')
            if isinstance(author_obj, dict):
                mapped_art["author"] = author_obj.get('name', 'Braj Rasik Heritage')
                
            # Tags list combining all types
            tags_clean = [t.get('name', '') if isinstance(t, dict) else t for t in raw_art.get('tags', [])]
            tags_clean.extend([s.get('name', '') if isinstance(s, dict) else s for s in raw_art.get('saints', [])])
            tags_clean.extend([d.get('name', '') if isinstance(d, dict) else d for d in raw_art.get('dhams', [])])
            mapped_art["tags"] = list(set(tags_clean))
            
            # Image mapping
            if raw_art.get('image'):
                mapped_art["image_urls"] = [raw_art.get('image')]
                
            # Set ID
            u_id = existing_id if existing_id else str(uuid.uuid4())
            mapped_art["id"] = u_id
            article_slug_to_id[slug] = u_id
            
            # Perform merge with existing row in database
            if existing_row:
                merged_art = merge_records(existing_row, mapped_art)
                upsert_batch.append(merged_art)
            else:
                upsert_batch.append(mapped_art)
                
            # Collect junction mappings
            # 1. Tags & Saints (from type list AND tags list)
            valid_tag_ids = set(synced_lookups.get('tags', {}).keys())
            for tag_ref in raw_art.get('tags', []):
                t_id = tag_ref.get('tag_id') if isinstance(tag_ref, dict) else tag_ref
                if t_id and t_id in valid_tag_ids:
                    junction_tags.append({"content_id": u_id, "tag_id": t_id})
                elif isinstance(tag_ref, str) and tag_ref in valid_tag_ids:
                    junction_tags.append({"content_id": u_id, "tag_id": tag_ref})
                
            for saint_ref in raw_art.get('saints', []):
                t_id = saint_ref.get('tag_id') if isinstance(saint_ref, dict) else saint_ref
                if t_id and t_id in valid_tag_ids:
                    junction_tags.append({"content_id": u_id, "tag_id": t_id})
                elif isinstance(saint_ref, str) and saint_ref in valid_tag_ids:
                    junction_tags.append({"content_id": u_id, "tag_id": saint_ref})

            for type_ref in raw_art.get('type', []):
                t_id = type_ref.get('id') if isinstance(type_ref, dict) else type_ref
                if t_id and t_id in valid_tag_ids:
                    junction_tags.append({"content_id": u_id, "tag_id": t_id})
                elif isinstance(type_ref, str) and type_ref in valid_tag_ids:
                    junction_tags.append({"content_id": u_id, "tag_id": type_ref})

            # 2. Places / Dhams
            for dham_ref in raw_art.get('dhams', []):
                p_id = dham_ref.get('place_id') if isinstance(dham_ref, dict) else dham_ref
                if p_id:
                    junction_places.append({"content_id": u_id, "place_id": p_id})
                elif isinstance(dham_ref, str):
                    junction_places.append({"content_id": u_id, "place_id": dham_ref})
            
            # Map places via referenced album_photos
            for album_ref in raw_art.get('album_photos', []):
                if isinstance(album_ref, dict):
                    alb_id = album_ref.get('album_id')
                    if alb_id and alb_id in album_to_places:
                        for p_id in album_to_places[alb_id]:
                            junction_places.append({"content_id": u_id, "place_id": p_id})

            # 3. Medias via referenced album_photos
            for album_ref in raw_art.get('album_photos', []):
                if isinstance(album_ref, dict):
                    alb_id = album_ref.get('album_id')
                    if alb_id and alb_id in album_to_medias:
                        for m_id in album_to_medias[alb_id]:
                            junction_medias.append({"content_id": u_id, "media_id": m_id})
                
            # 4. Raags
            for raag_ref in raw_art.get('raag', []):
                r_id = raag_ref.get('raag_id') if isinstance(raag_ref, dict) else raag_ref
                if r_id:
                    junction_raags.append({"content_id": u_id, "raag_id": r_id})
                
            # 5. Subjects
            for sub_ref in raw_art.get('subject', []):
                s_id = sub_ref.get('subject_id') if isinstance(sub_ref, dict) else sub_ref
                if s_id:
                    junction_subjects.append({"content_id": u_id, "subject_id": s_id})
                
        # Perform upsert
        try:
            client.table('content').upsert(upsert_batch).execute()
            articles_success += len(upsert_batch)
            logger.info(f"  Upserted articles batch {i//batch_size + 1}/{(total_articles//batch_size)+1}...")
        except Exception as e:
            logger.error(f"❌ Failed to upsert articles batch: {e}")
            
    logger.info(f"✅ Finished syncing articles (content): {articles_success}/{total_articles} records.")
    
    # 3. Sync Junction Relationships (Many-to-Many)
    logger.info("Syncing relational junction tables...")
    
    # Pre-filter junctions to make sure keys actually exist in lookups
    valid_tags = set(synced_lookups.get('tags', {}).keys())
    valid_places = set(synced_lookups.get('places', {}).keys())
    valid_raags = set(synced_lookups.get('raags', {}).keys())
    valid_subjects = set(synced_lookups.get('subjects', {}).keys())
    valid_medias = set(synced_lookups.get('medias', {}).keys())
    
    clean_j_tags = [j for j in junction_tags if j["tag_id"] in valid_tags]
    clean_j_places = [j for j in junction_places if j["place_id"] in valid_places]
    clean_j_raags = [j for j in junction_raags if j["raag_id"] in valid_raags]
    clean_j_subjects = [j for j in junction_subjects if j["subject_id"] in valid_subjects]
    clean_j_medias = [j for j in junction_medias if j["media_id"] in valid_medias]
    
    # Upload Junctions
    sync_junction_table("article_tags", clean_j_tags)
    sync_junction_table("article_places", clean_j_places)
    sync_junction_table("article_raags", clean_j_raags)
    sync_junction_table("article_subjects", clean_j_subjects)
    sync_junction_table("article_medias", clean_j_medias)
    
    logger.info("🎉 Database Relational Sync successfully complete!")

def sync_junction_table(table_name, list_data, batch_size=200):
    if not list_data:
        logger.info(f"No records for junction table '{table_name}'")
        return
        
    if not check_table_exists(table_name):
        logger.warning(f"⚠️ Skipping junction table '{table_name}' - table does not exist in schema.")
        return
        
    logger.info(f"Syncing junction table '{table_name}' ({len(list_data)} records)...")
    
    # Deduplicate junctions
    unique_list = []
    seen = set()
    for row in list_data:
        # Create a unique key tuple
        keys = tuple(row.values())
        if keys not in seen:
            seen.add(keys)
            unique_list.append(row)
            
    total = len(unique_list)
    success_count = 0
    
    for i in range(0, total, batch_size):
        batch = unique_list[i:i+batch_size]
        try:
            client.table(table_name).upsert(batch).execute()
            success_count += len(batch)
        except Exception as e:
            logger.error(f"❌ Failed to upsert batch in junction '{table_name}': {e}")
            
    logger.info(f"✅ Sync complete for junction '{table_name}': {success_count}/{total} records.")

if __name__ == "__main__":
    main()
