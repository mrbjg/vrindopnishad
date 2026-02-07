#!/usr/bin/env python3
"""
Format the 216 Saint biographies for Supabase upload.
The data was collected via browser automation during the exploration phase.
"""
import json

# Sample saint data structure from browser subagent output
saints_data = [
  {
    "name": "स्वामी श्री हरिदास",
    "bio": "स्वामी श्री हरिदास, वृंदावन के रसिक शिरोमणि संत थे, जो श्री ललिता सखी के अवतार थे, जो श्री राधारानी की मुख्य सखी हैं। स्वामी हरिदास जी ने 'केलिमाल' की रचना में 'अखंड नित्य विहार' रस निकुंज उपासना को प्रस्तुत किया है ।",
    "link": "https://www.brajrasik.org/hi/tag/haridas"
  },
  {
    "name": "श्री हित हरिवंश महाप्रभु",
    "bio": "श्री हित हरिवंश महाप्रभु, श्री वृंदावन धाम के रसिक शिरोमणि संत और श्री कृष्ण की वंशी के अवतार हैं। वे श्री राधारानी को ही अपना गुरु और इष्ट मानते हैं और राधावल्लभ संप्रदाय के मुख्य आचार्य हैं। इनकी उपासना में मुख्य रूप से सहचरी भाव है, जिसमें श्री राधा चरण प्रधानता है।",
    "link": "https://www.brajrasik.org/hi/tag/hitharivansh"
  }
]

# Note: The browser collected 216 saints, but the data wasn't persisted to a file.
# For now, I'll create a placeholder structure. In production, we'd need to re-run
# the browser extraction or use an alternative method.

print("Creating Saint biography upload format...")
print(f"Saints extracted: {len(saints_data)} (sample)")
print("\nNote: Full 216 saint dataset requires re-extraction via browser automation.")
print("Current dataset is a sample for format verification.")

output_file = "/Users/mr.bajrangi/Code/Company/Projects/VrindaVaani/admin/saints_formatted.json"

# Format for Supabase content table
formatted_saints = []
for saint in saints_data:
    formatted_saints.append({
        "title": saint["name"],
        "hindi_text": saint["bio"],
        "english_translation": "",  # Would need to scrape English pages
        "description": saint["link"],
        "tags": ["Braj Rasik", "Saint", "Biography"],
        "author": "BrajRasik.org",
        "category": "saint_biography"
    })

with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(formatted_saints, f, indent=2, ensure_ascii=False)

print(f"\nSaved formatted data to: {output_file}")
print("Ready for Supabase upload (after full extraction)")
