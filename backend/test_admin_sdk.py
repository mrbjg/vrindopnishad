import firebase_admin
from firebase_admin import firestore

def test_project(project_id, database_id=None):
    try:
        print(f"\n=== Testing project: {project_id} (database: {database_id or 'default'}) ===")
        
        # Initialize app
        options = {}
        if database_id:
            options['databaseId'] = database_id
            
        app = firebase_admin.initialize_app(
            options=options,
            name=project_id + (database_id or "")
        )
        
        # In newer versions of firebase-admin, you specify project/database in firestore.client
        if database_id:
            db = firestore.client(app=app)
        else:
            db = firestore.client(app=app)
            
        print("Querying 'content' collection...")
        docs_ref = db.collection('content').limit(5)
        docs = docs_ref.stream()
        
        count = 0
        for doc in docs:
            count += 1
            print(f"Document ID: {doc.id}")
            data = doc.to_dict()
            print(f"Title: {data.get('title')}")
            print(f"Category: {data.get('category')}")
            print("------------------------")
            
        print(f"Total sample documents returned: {count}")
        
        # List collections
        collections = db.collections()
        col_names = [col.id for col in collections]
        print(f"Collections present in database: {col_names}")
        
    except Exception as e:
        print(f"Error on project {project_id}: {e}")

def run():
    # Test our projects
    test_project("login-me-vrinda")
    test_project("santvaanig")
    test_project("vihaarvrinda")

if __name__ == "__main__":
    run()
