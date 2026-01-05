import os
import firebase_admin
from firebase_admin import credentials, firestore

def test_firebase():
    try:
        cred_path = 'firebase-credentials.json'
        if not os.path.exists(cred_path):
            print("Error: firebase-credentials.json not found")
            return

        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        
        # Test write
        print("Testing Firestore write...")
        test_ref = db.collection('test_connection').document('status')
        test_ref.set({
            'connected': True,
            'timestamp': firestore.SERVER_TIMESTAMP,
            'message': 'Backend connection verified'
        })
        print("Write successful!")
        
        # Test read
        print("Testing Firestore read...")
        doc = test_ref.get()
        if doc.exists:
            print(f"Read successful: {doc.to_dict()}")
        else:
            print("Read failed: document not found")
            
    except Exception as e:
        print(f"Firebase test failed: {e}")

if __name__ == "__main__":
    test_firebase()
