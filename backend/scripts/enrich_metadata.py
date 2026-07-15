import os
import json
import re
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client

# Load environment
SCRIPT_DIR = Path(__file__).parent
BACKEND_DIR = SCRIPT_DIR.parent
load_dotenv(BACKEND_DIR / '.env')

# Supabase Client Setup
url = os.environ.get('SUPABASE_URL', '')
key = os.environ.get('SUPABASE_SERVICE_ROLE_KEY') or os.environ.get('SUPABASE_ANON_KEY', '')
supabase_client = create_client(url, key)

def enrich_item(item):
    # 1. Update author name
    author = (item.get('author') or '').strip()
    if author in ['', 'Team VrindaVaani', 'General', 'Shloka', 'braj-rasik-heritage']:
        item['author'] = 'Team VrindaVaani'
        
    # 2. Clean existing tags
    old_tags = item.get('tags') or []
    new_tags = []
    for tag in old_tags:
        tag_clean = tag.strip()
        if tag_clean == 'Vrindavan devotee':
            new_tags.append('VrindaVaani')
        elif tag_clean == 'Mass Import':
            continue
        elif tag_clean not in new_tags:
            new_tags.append(tag_clean)
            
    # 3. Content-based tagging
    title = (item.get('title') or '').lower()
    sanskrit = (item.get('sanskrit_text') or '').lower()
    hindi = (item.get('hindi_text') or '').lower()
    english = (item.get('english_translation') or '').lower()
    
    text_corpus = f"{title} {sanskrit} {hindi} {english}"
    
    # Keyword sets
    radha_keywords = ['राधा', 'राधे', 'किशोरी', 'प्रिया', 'लाड़ली', 'भानु', 'radha', 'radhe', 'kishori', 'priya', 'ladli']
    krishna_keywords = ['कृष्ण', 'श्याम', 'मोहन', 'गिरिधर', 'माधव', 'कान्हा', 'shyam', 'krishna', 'krishn', 'madhav', 'mohan']
    vrindavan_keywords = ['वृंदावन', 'वृन्दावन', 'निकुंज', 'यमुना', 'कालिंदी', 'कुंज', 'dham', 'vrindavan', 'nikunj', 'yamuna']
    love_keywords = ['प्रेम', 'नेह', 'अनुराग', 'प्रीति', 'प्यार', 'love', 'prem', 'anurag']
    rasa_keywords = ['रस', 'माधुरी', 'आनंद', 'स्वाद', 'rasa', 'ras', 'madhuri', 'anand']
    bhakti_keywords = ['भक्ति', 'शरण', 'भक्त', 'सेवा', 'bhakti', 'sharan', 'seva']
    guru_keywords = ['गुरु', 'कृपालु', 'आचार्य', 'स्वामी', 'guru', 'kripalu', 'swami']
    leela_keywords = ['लीला', 'विहार', 'रास', 'नृत्य', 'खेल', 'leela', 'rasa-lila']
    
    # Match and append tags
    if any(k in text_corpus for k in radha_keywords):
        if 'Shri Radha' not in new_tags:
            new_tags.append('Shri Radha')
    if any(k in text_corpus for k in krishna_keywords):
        if 'Shri Krishna' not in new_tags:
            new_tags.append('Shri Krishna')
    if any(k in text_corpus for k in vrindavan_keywords):
        if 'Vrindavan Dham' not in new_tags:
            new_tags.append('Vrindavan Dham')
    if any(k in text_corpus for k in love_keywords):
        if 'Divine Love' not in new_tags:
            new_tags.append('Divine Love')
    if any(k in text_corpus for k in rasa_keywords):
        if 'Rasa' not in new_tags:
            new_tags.append('Rasa')
    if any(k in text_corpus for k in bhakti_keywords):
        if 'Bhakti' not in new_tags:
            new_tags.append('Bhakti')
    if any(k in text_corpus for k in guru_keywords):
        if 'Guru Mahima' not in new_tags:
            new_tags.append('Guru Mahima')
    if any(k in text_corpus for k in leela_keywords):
        if 'Leela' not in new_tags:
            new_tags.append('Leela')
            
    # Always ensure VrindaVaani tag is present for recommendations
    if 'VrindaVaani' not in new_tags:
        new_tags.append('VrindaVaani')
        
    item['tags'] = new_tags
    return item

def main():
    db_path = Path(__file__).parent.parent.parent / 'frontend/data/vrindavaani_content.json'
    if not db_path.exists():
        print(f"Error: Database file not found at {db_path}")
        return
        
    print(f"Loading database from {db_path}...")
    with open(db_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f"Loaded {len(data)} records.")
    
    print("Enriching metadata...")
    for item in data:
        enrich_item(item)
        
    # Save local database
    with open(db_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Enriched database saved to {db_path}")
    
    # Upload changes to Supabase in batches of 1000
    print("Uploading enriched fields to Supabase...")
    batch_size = 1000
    total = len(data)
    for i in range(0, total, batch_size):
        batch = data[i:i+batch_size]
        updates = []
        for item in batch:
            updates.append({
                'id': item['id'],
                'author': item['author'],
                'tags': item['tags']
            })
            
        try:
            # Using upsert to update author and tags fields by ID
            supabase_client.table('verses').upsert(updates).execute()
            print(f"Supabase progress: {min(i+batch_size, total)}/{total} updated.")
        except Exception as e:
            print(f"Error uploading batch at index {i}: {e}")
            
    print("Enrichment and Supabase sync complete!")

if __name__ == '__main__':
    main()
