import json
import requests
import time

# Configuration
SUPABASE_URL = "https://tilimltxgeucefxzerqi.supabase.co"
SUPABASE_KEY = "sb_publishable_0YiM-Q8itRORUDdToracaQ_vzcrjUlC"
REST_URL = f"{SUPABASE_URL}/rest/v1/content"
JSON_FILE = "/Users/mr.bajrangi/Code/Company/Projects/VrindaVaani/admin/brajrasik_dual_full.json"

def upload_data():
    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal"
    }

    # 1. Delete Existing Braj Rasik Content to avoid duplicates/errors
    print("Deleting existing Braj Rasik records from Supabase...")
    try:
        # Filter for records with "Braj Rasik" in the tags array
        delete_url = f"{REST_URL}?tags=cs.%7BBraj%20Rasik%7D" 
        response = requests.delete(delete_url, headers=headers)
        if response.status_code in [200, 204]:
            print("  Successfully cleared existing records.")
        else:
            print(f"  Warning: Delete returned {response.status_code} - {response.text}")
    except Exception as e:
        print(f"  Delete error: {e}")

    # 2. Read new data
    print(f"Reading data from {JSON_FILE}...")
    try:
        with open(JSON_FILE, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error reading JSON: {e}")
        return

    print(f"Found {len(data)} items to upload.")
    
    # Supabase Schema Mapping & Cleaning
    cleaned_data = []
    for item in data:
        clean_item = {
            "title": item.get("title"),
            "category": item.get("category", "General"),
            "sanskrit_text": item.get("sanskrit_text"),
            "hindi_text": item.get("hindi_text"),
            "english_text": item.get("english_text"),
            "english_translation": item.get("english_translation"),
            "description": item.get("description"), # The unique URL
            "author": item.get("author", ""),
            "status": item.get("status", "published"),
            "content_text": item.get("content_text", ""),
            "tags": item.get("tags", ["Braj Rasik", "Mass Import"]),
            "image_urls": item.get("image_urls", []),
            "video_urls": item.get("video_urls", []),
            "media_links": item.get("media_links", [])
        }
        cleaned_data.append(clean_item)

    # 3. Batch Insertion
    batch_size = 50
    for i in range(0, len(cleaned_data), batch_size):
        batch = cleaned_data[i:i + batch_size]
        print(f"Uploading batch {i//batch_size + 1} ({i} to {i + len(batch)})...")
        
        try:
            response = requests.post(REST_URL, headers=headers, json=batch)
            if response.status_code in [201, 204]:
                print(f"  Successfully uploaded {len(batch)} items.")
            else:
                print(f"  Error uploading batch: {response.status_code} - {response.text}")
                time.sleep(2)
        except Exception as e:
            print(f"  Connection error: {e}")
            time.sleep(5)
        except Exception as e:
            print(f"  Connection error: {e}")
            time.sleep(5)
            
    print("Upload process complete.")

if __name__ == "__main__":
    upload_data()
