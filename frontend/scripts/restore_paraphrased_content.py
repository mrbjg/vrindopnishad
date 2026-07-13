import json
import os
import re
import subprocess
from pathlib import Path

def strip_english_sentences(text):
    if not text:
        return ""
    lines = text.split('\n')
    cleaned_lines = []
    for line in lines:
        # Split by sentence boundaries: . ! ? । ॥ :
        sentences = re.split(r'(?<=[.!?।॥:])\s+', line)
        cleaned_sentences = []
        for sentence in sentences:
            trimmed = sentence.strip()
            if not trimmed:
                continue
            # Check if it contains at least one Devanagari character
            has_devanagari = any('\u0900' <= c <= '\u097f' for c in trimmed)
            if has_devanagari:
                cleaned_sentences.append(trimmed)
        if cleaned_sentences:
            cleaned_lines.append(" ".join(cleaned_sentences))
    return "\n".join(cleaned_lines)

def classify_item_category(item):
    if not item:
        return 'poem'
    
    raw_cat = str(item.get('category') or '').lower().strip()
    
    if raw_cat in ['saint', 'dham']:
        return raw_cat
        
    if raw_cat in ['strotra', 'strotras', 'stotra', 'storas']:
        return 'strotra'
        
    if raw_cat in ['poem', 'poems', 'poetry']:
        return 'poem'
        
    title = str(item.get('title') or '').lower()
    sanskrit = str(item.get('sanskrit_text') or '').lower()
    
    strotra_keywords = [
        'स्तोत्र', 'strotra', 'stotra',
        'शतक', 'shatak',
        'अष्टक', 'ashtak',
        'महिमामृत', 'mahimamrit',
        'सुधानिधि', 'sudhanidhi',
        'सहस्रनाम', 'sahasranam'
    ]
    
    has_strotra_keyword = any(k in title for k in strotra_keywords) or \
                          any(k in sanskrit for k in ['स्तोत्र', 'strotra', 'stotra'])
                          
    if has_strotra_keyword:
        return 'strotra'
        
    sanskrit_trimmed = sanskrit.strip()
    has_sanskrit_text = False
    if len(sanskrit_trimmed) > 10:
        has_marker = '॥' in sanskrit or '।' in sanskrit or 'ॐ' in sanskrit
        has_long_english = bool(re.search(r'[a-z]{5,}', sanskrit))
        if has_marker or not has_long_english:
            has_sanskrit_text = True
            
    is_scripture_book = any(k in title for k in ['gita', 'गीता', 'upnishad', 'उपनिषद', 'samhita', 'संहिता', 'purana', 'पुराण', 'shloka', 'श्लोक'])
    
    if is_scripture_book or has_sanskrit_text or raw_cat in ['shloka', 'shlokas']:
        return 'shloka'
        
    return 'poem'

def main():
    base_dir = Path("/Users/sakhi/Code/Company/Projects/Sant-Vaani/frontend")
    content_file = base_dir / "data/vrindavaani_content.json"
    saints_path = base_dir / "data/saints_formatted.json"

    print("Loading current vrindavaani_content.json...")
    with open(content_file, 'r', encoding='utf-8') as f:
        current_data = json.load(f)
    print(f"Loaded {len(current_data)} current items.")

    print("Extracting paraphrased vrindavaani_content.json from commit c5124c1...")
    try:
        git_show_output = subprocess.check_output(
            ['git', 'show', 'c5124c1:frontend/data/vrindavaani_content.json'],
            stderr=subprocess.PIPE
        )
        paraphrased_data = json.loads(git_show_output.decode('utf-8'))
        print(f"Loaded {len(paraphrased_data)} items from commit c5124c1.")
    except Exception as e:
        print(f"Error loading commit c5124c1: {e}")
        return

    # Build lookup mappings from the paraphrased dataset
    para_by_id = {}
    para_by_sanskrit = {}
    para_by_title = {}

    for item in paraphrased_data:
        p_id = item.get("id")
        p_hindi = item.get("hindi_text", "")
        p_sanskrit = item.get("sanskrit_text", "")
        p_title = item.get("title", "")
        
        if p_id:
            para_by_id[p_id] = p_hindi
        if p_sanskrit and p_sanskrit.strip():
            para_by_sanskrit[p_sanskrit.strip()] = p_hindi
        if p_title and p_title.strip():
            para_by_title[p_title.strip()] = p_hindi

    # Apply restoration
    restored_count = 0
    skipped_count = 0

    for item in current_data:
        p_id = item.get("id")
        p_sanskrit = item.get("sanskrit_text", "").strip()
        p_title = item.get("title", "").strip()
        
        para_hindi = None
        if p_id in para_by_id:
            para_hindi = para_by_id[p_id]
        elif p_sanskrit in para_by_sanskrit:
            para_hindi = para_by_sanskrit[p_sanskrit]
        elif p_title in para_by_title:
            para_hindi = para_by_title[p_title]

        # Wiping copyrighted English fields for DMCA compliance
        item["english_text"] = ""
        item["english_translation"] = ""
        item["description"] = ""

        # Set or restore Hindi text
        if para_hindi and para_hindi.strip():
            item["hindi_text"] = para_hindi.strip()
            restored_count += 1
        else:
            # Fallback: Strip English from whatever is in hindi_text
            orig_hindi = item.get("hindi_text") or ""
            clean_hindi = strip_english_sentences(orig_hindi)
            # If it was the original long copyrighted explanation, clear it or keep stripped
            # Usually if it is not in the paraphrased commit, we should clear it to be safe
            item["hindi_text"] = clean_hindi.strip()
            skipped_count += 1

        # Reconstruct content_text (Devanagari/Sanskrit only)
        parts = []
        if item.get("sanskrit_text"):
            parts.append(item["sanskrit_text"])
        if item.get("author"):
            parts.append(f"- {item['author']}")
        if item.get("hindi_text"):
            parts.append(item["hindi_text"])
            
        raw_content_text = "\n".join(parts)
        item["content_text"] = strip_english_sentences(raw_content_text).strip()

    print(f"Restoration complete: Restored {restored_count} paraphrased explanations, processed {skipped_count} fallbacks.")

    # Save to disk
    with open(content_file, 'w', encoding='utf-8') as f:
        json.dump(current_data, f, ensure_ascii=False, indent=2)
    print(f"Saved vrindavaani_content.json successfully.")

    # Save backups
    public_data_dir = base_dir / 'public/data'
    backup_file = public_data_dir / 'content_backup.json'
    with open(backup_file, 'w', encoding='utf-8') as f:
        json.dump(current_data, f, ensure_ascii=False, indent=2)
    print(f"Saved content_backup.json.")

    # Save category-specific files
    raw_saints = []
    if os.path.exists(saints_path):
        try:
            with open(saints_path, 'r', encoding='utf-8') as f:
                raw_saints = json.load(f)
        except Exception as e:
            print(f"Warning: Failed to load saints: {e}")

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
            cat_verses = [v for v in current_data if classify_item_category(v) == cat]
            
        with open(cat_file, 'w', encoding='utf-8') as f:
            json.dump(cat_verses, f, ensure_ascii=False, indent=2)
        print(f"Saved category split ({cat}) with {len(cat_verses)} items.")

if __name__ == '__main__':
    main()
