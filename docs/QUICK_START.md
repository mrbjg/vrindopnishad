# Quick Start Guide - Sant-Vaani (Vrindopnishad)

Get the application running in 10 minutes with this simplified setup guide.

## Option 1: Quick Demo Mode (No Firebase Required)
Perfect for testing the UI without setting up Firebase.

### Frontend Only
```bash
cd frontend
yarn install
yarn start
```
- Opens at `http://localhost:3000`
- Browse categories, view sample content (mock data)
- Admin login shows authentication flow

## Option 2: Full Setup with Firebase (Recommended)

### Prerequisites
- Node.js 18+ installed
- Python 3.8+ installed
- Google account for Firebase

### Step 1: Install Dependencies

#### Frontend
```bash
cd frontend
yarn install
```

#### Backend
```bash
cd backend
pip install -r requirements.txt
```

### Step 2: Firebase Setup (5 minutes)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" and name it `vrindopnishad`
3. Enable these services:
   - **Firestore Database** (Production mode)
   - **Storage** (For media files)
   - **Authentication** (Email/Password)

4. Get credentials:
   - Go to **Project Settings** → **Service Accounts**
   - Click **Generate new private key**
   - Save as `backend/firebase-credentials.json`

5. Get storage bucket name:
   - Go to **Storage**
   - Copy the bucket name from the URL (format: `project-id.appspot.com`)

### Step 3: Configure Environment

Create `.env` file in `/backend/`:
```env
# Firebase
FIREBASE_CREDENTIALS_PATH=./firebase-credentials.json
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com

# Admin Auth
ADMIN_EMAIL=admin@vrindopnishad.com
ADMIN_PASSWORD=admin123

# Server
JWT_SECRET_KEY=your-secret-key-here
CORS_ORIGINS=http://localhost:3000,http://localhost:8000,https://your-domain.com

# Optional: AI Features
EMERGENT_LLM_KEY=your-key-here
GOOGLE_APPLICATION_CREDENTIALS=./firebase-credentials.json
```

### Step 4: Run the Application

#### Terminal 1 - Backend
```bash
cd backend
python -m uvicorn server:app --reload --host 0.0.0.0 --port 8000
```

#### Terminal 2 - Frontend
```bash
cd frontend
yarn start
```

#### Access the App
- **Frontend**: http://localhost:3000
- **API Docs**: http://localhost:8000/docs
- **Admin Login**: Navigate to `/admin/login`
  - Email: `admin@vrindopnishad.com`
  - Password: `admin123`

## Firestore Database Rules

After creating Firestore, set these rules in **Database Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow public read to all content
    match /content/{document=**} {
      allow read: if true;
      allow write: if false;
    }
    
    // Deny other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Storage Security Rules

Set these rules in **Storage Rules**:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

## Troubleshooting

### Firebase credentials not found
- Ensure `firebase-credentials.json` is in `/backend/` directory
- Check file permissions: `chmod 600 backend/firebase-credentials.json`

### Port already in use
```bash
# Change backend port
python -m uvicorn server:app --port 9000

# Change frontend port
PORT=3001 yarn start
```

### CORS errors
- Add your frontend URL to `CORS_ORIGINS` in `.env`
- Example: `CORS_ORIGINS=http://localhost:3000,https://myapp.com`

### Database connection issues
- Verify Firebase project ID in `.env`
- Check service account has `Editor` role
- Ensure Firestore is enabled in Firebase Console

## Project Structure
```
Sant-Vaani/
├── frontend/          # React application
│   ├── src/
│   ├── public/
│   └── package.json
├── backend/           # FastAPI server
│   ├── server.py
│   ├── requirements.txt
│   └── .env
└── tests/            # Test suite
```

## Next Steps

1. **Add Content**
   - Login to admin dashboard
   - Create new content with Sanskrit/Hindi/English text
   - Upload audio, images, or generate with AI

2. **Customize**
   - Modify colors in `frontend/src/App.css`
   - Update admin credentials in `.env`
   - Add custom domains in Firebase

3. **Deploy**
   - Deploy frontend to Vercel/Netlify
   - Deploy backend to Railway/Render
   - Update `CORS_ORIGINS` in `.env`

## Support

For issues:
1. Check the detailed `FIREBASE_SETUP_GUIDE.md`
2. Review API documentation at `/docs` endpoint
3. Check browser console for frontend errors
4. Check terminal logs for backend errors

---

**Happy building! 🙏**
