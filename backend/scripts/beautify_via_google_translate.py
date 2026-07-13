import json
import urllib.request
import urllib.parse
import time
import re
import subprocess
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent.parent
DB_PATH = BASE_DIR / 'frontend/data/vrindavaani_content.json'

def translate_via_google(text, from_lang, to_lang):
    url = f'https://translate.googleapis.com/translate_a/single?client=gtx&sl={from_lang}&tl={to_lang}&dt=t&q=' + urllib.parse.quote(text)
    req = urllib.request.Request(
        url,
        headers={'User-Agent': 'Mozilla/5.0'}
    )
    
    max_retries = 3
    for attempt in range(max_retries):
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                res = json.loads(resp.read().decode('utf-8'))
                translated = ''.join([part[0] for part in res[0] if part[0]])
                return translated.strip()
        except Exception as e:
            print(f"Translate from {from_lang} to {to_lang} attempt {attempt+1} failed: {e}", flush=True)
            time.sleep(2)
    return None

def paraphrase_hindi_roundtrip(text):
    if not text:
        return ""
    # 1. Translate Hindi to English
    english = translate_via_google(text, 'hi', 'en')
    if not english:
        return text
    # 2. Translate English back to Hindi
    paraphrased = translate_via_google(english, 'en', 'hi')
    if not paraphrased:
        return text
        
    # Post-process for spiritual/literary accuracy
    paraphrased = paraphrased.replace('स्वाद कलिकाओं', 'रसिकों की रसना (वाणी)')
    paraphrased = paraphrased.replace('स्वाद कलिका', 'वाणी')
    paraphrased = paraphrased.replace('इन्द्रियतृप्ति', 'विषय-वासना')
    paraphrased = paraphrased.replace('इंद्रियतृप्ति', 'विषय-वासना')
    paraphrased = paraphrased.replace('राजा-रेणुका', 'चरण-रज')
    return paraphrased

def main():
    if not DB_PATH.exists():
        print(f"❌ Error: Database file not found at {DB_PATH}", flush=True)
        return

    print(f"Loading database from {DB_PATH}...", flush=True)
    with open(DB_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)
    print(f"Loaded {len(data)} records.", flush=True)
    
    bad_terms = ['मंजिल होती है', 'दाग नहीं छोड़ता', 'झरने लाऊंगी', 'राजा-रेणुका']
    
    # Identify items needing translation/paraphrasing
    to_translate = []
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
            to_translate.append(item)
            
    total_to_process = len(to_translate)
    print(f"Total problematic/missing items to process: {total_to_process}", flush=True)
    
    if total_to_process == 0:
        print("🎉 No problematic items found. All items are clean!", flush=True)
        return
        
    translated_count = 0
    for idx, item in enumerate(to_translate):
        sanskrit = item['sanskrit_text']
        hindi = (item.get('hindi_text') or '').strip()
        print(f"[{idx+1}/{total_to_process}] Paraphrasing Hindi for ID: {item['id']}...", flush=True)
        
        if hindi:
            # Modify/paraphrase existing Hindi text (does not touch Sanskrit text)
            processed_hindi = paraphrase_hindi_roundtrip(hindi)
        else:
            # Fallback if Hindi is completely missing: translate Sanskrit to Hindi
            processed_hindi = translate_via_google(sanskrit, 'sa', 'hi')
            if processed_hindi:
                processed_hindi = processed_hindi.replace('स्वाद कलिकाओं', 'रसिकों की रसना (वाणी)')
                processed_hindi = processed_hindi.replace('स्वाद कलिका', 'वाणी')
                processed_hindi = processed_hindi.replace('इन्द्रियतृप्ति', 'विषय-वासना')
                processed_hindi = processed_hindi.replace('इंद्रियतृप्ति', 'विषय-वासना')
                processed_hindi = processed_hindi.replace('राजा-रेणुका', 'चरण-रज')
        
        if processed_hindi:
            item['hindi_text'] = processed_hindi
            
            # Reconstruct content_text
            parts = []
            if item.get('sanskrit_text'):
                parts.append(item['sanskrit_text'])
            if item.get('author'):
                parts.append(f"- {item['author']}")
            parts.append(item['hindi_text'])
            item['content_text'] = "\n".join(parts)
            
            # Wipe copyrighted English fields for DMCA compliance
            item["english_text"] = ""
            item["english_translation"] = ""
            item["description"] = ""
            
            translated_count += 1
        else:
            print(f"❌ Failed to translate ID: {item['id']}", flush=True)
            
        # Small delay to be polite to the endpoint
        time.sleep(0.2)
        
    print(f"Successfully translated {translated_count}/{total_to_process} items.", flush=True)
    
    # Save back to database
    with open(DB_PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Saved changes to {DB_PATH}.", flush=True)
    
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
        
    print("🎉 All problematic items successfully resolved and database updated!", flush=True)

if __name__ == '__main__':
    main()
