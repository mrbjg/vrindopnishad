import json
import os
import re

db_path = "/Users/sakhi/Code/Company/Projects/Sant-Vaani/frontend/data/vrindavaani_content.json"

if not os.path.exists(db_path):
    print("Error: Database file not found")
    exit(1)

with open(db_path, "r", encoding="utf-8") as f:
    data = json.load(f)

print(f"Loaded {len(data)} items from database.")

cleaned_count = 0

for item in data:
    sanskrit = item.get("sanskrit_text", "")
    if not sanskrit:
        continue
        
    lines = sanskrit.split("\n")
    attr_idx = -1
    for i, line in enumerate(lines):
        trimmed = line.strip()
        # Match lines starting with -, —, or – (dash/hyphen indicators)
        if trimmed.startswith("-") or trimmed.startswith("—") or trimmed.startswith("–"):
            attr_idx = i
            break
            
    if attr_idx != -1 and attr_idx < len(lines) - 1:
        # Check if there is any trailing non-empty text
        trailing = [l.strip() for l in lines[attr_idx+1:] if l.strip()]
        if trailing:
            # Cut off everything after the attribution line
            cleaned_sanskrit = "\n".join(lines[:attr_idx+1]).strip()
            item["sanskrit_text"] = cleaned_sanskrit
            
            # Reconstruct content_text
            parts = []
            if cleaned_sanskrit:
                parts.append(cleaned_sanskrit)
            if item.get("hindi_text"):
                parts.append(item["hindi_text"].strip())
            
            item["content_text"] = "\n".join(parts).strip()
            cleaned_count += 1

print(f"Successfully cleaned {cleaned_count} items with appended descriptions.")

with open(db_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("✅ Saved updated database back to disk.")
