from supabase_client import SupabaseDB
import uuid

db = SupabaseDB()
test_data = {
    "id": str(uuid.uuid4()),
    "title": "Test Column",
    "category": "Test",
    "content_text": "testing if this column exists",
    "tags": ["test"]
}

try:
    result = db.create_content(test_data)
    print("Insert successful!")
    print(result)
except Exception as e:
    print(f"Insert failed: {e}")
