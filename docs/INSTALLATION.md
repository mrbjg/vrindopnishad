# Installation Guide - Sant-Vaani

Complete guide to get Sant-Vaani (Vrindopnishad) running on your machine.

## Table of Contents
1. [Quick Demo (5 minutes)](#quick-demo-5-minutes)
2. [Full Setup with Firebase (15 minutes)](#full-setup-with-firebase-15-minutes)
3. [Troubleshooting](#troubleshooting)
4. [File Structure](#file-structure)

---

## Quick Demo (5 minutes)

### Zero Configuration - No Firebase Needed
This is the **easiest way** to test the application with sample data.

### macOS/Linux:
```bash
cd /path/to/Sant-Vaani
chmod +x start-demo.sh
./start-demo.sh
```

### Windows (Command Prompt):
```batch
cd path\to\Sant-Vaani
npm install --prefix frontend
npm start --prefix frontend
```

### What You Get:
✅ Beautiful UI with sample content  
✅ Browse categories, read sacred texts  
✅ Test admin login (`admin@vrindopnishad.com` / `admin123`)  
✅ No backend or database setup needed  

**Access:** http://localhost:3000

---

## Full Setup with Firebase (15 minutes)

### Prerequisites
- **Node.js 18+** - Download from https://nodejs.org
- **Python 3.8+** - Download from https://python.org
- **Google Account** - For Firebase Console access

### Step 1: Install Dependencies

#### macOS/Linux:
```bash
cd /path/to/Sant-Vaani
chmod +x setup.sh
./setup.sh
```

#### Windows:
```bash
cd path\to\Sant-Vaani

# Frontend
cd frontend
npm install
cd ..

# Backend
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
cd ..
```

### Step 2: Firebase Console Setup (5 minutes)

1. **Create Project**
   - Go to https://console.firebase.google.com/
   - Click "Create a project"
   - Name: `vrindopnishad` (or your choice)
   - Click "Create project"

2. **Enable Firestore Database**
   - In Firebase Console, click "Firestore Database"
   - Click "Create Database"
   - Select "Production mode"
   - Choose location closest to you
   - Click "Enable"

3. **Enable Cloud Storage**
   - Click "Storage"
   - Click "Get started"
   - Keep default settings
   - Click "Done"

4. **Enable Authentication** (Optional but recommended)
   - Click "Authentication"
   - Click "Get started"
   - Enable "Email/Password"

### Step 3: Get Credentials

1. **Service Account Key**
   - In Firebase, click gear icon ⚙️ → "Project Settings"
   - Go to "Service Accounts" tab
   - Click "Generate new private key"
   - A JSON file will download
   - Save it as: `backend/firebase-credentials.json`

2. **Storage Bucket Name**
   - In Firebase, go to "Storage"
   - Copy the bucket name from URL (format: `your-project-id.appspot.com`)

### Step 4: Configure .env

Edit `backend/.env`:

```env
# Firebase Configuration
FIREBASE_CREDENTIALS_PATH=./firebase-credentials.json
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com

# Admin Credentials (Change in production!)
ADMIN_EMAIL=admin@vrindopnishad.com
ADMIN_PASSWORD=admin123

# JWT Secret (Change this!)
JWT_SECRET_KEY=change-this-to-something-secret

# CORS - Allow your frontend
CORS_ORIGINS=http://localhost:3000,http://localhost:8000

# Optional: AI Features
# EMERGENT_LLM_KEY=your-key-here
```

Create `frontend/.env`:

```env
REACT_APP_BACKEND_URL=http://localhost:8000
REACT_APP_DEMO_MODE=false
```

### Step 5: Set Firestore Security Rules

In Firebase Console:
- Go to "Firestore Database"
- Click "Rules" tab
- Replace with this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Public read access to all content
    match /content/{document=**} {
      allow read: if true;
      allow write: if false;
    }
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```
Click "Publish"

### Step 6: Set Storage Security Rules

In Firebase Console:
- Go to "Storage"
- Click "Rules" tab
- Replace with this:

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
Click "Publish"

### Step 7: Run the Application

**Terminal 1 - Backend:**
```bash
cd backend

# macOS/Linux
source venv/bin/activate
python -m uvicorn server:app --reload

# Windows
venv\Scripts\activate
python -m uvicorn server:app --reload
```

Expected output:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

**Terminal 2 - Frontend:**
```bash
cd frontend

# macOS/Linux & Windows
yarn start
# or: npm start
```

Expected output:
```
webpack compiled
Compiled successfully!
```

### Step 8: Access the Application

- **Frontend:** http://localhost:3000
- **API Documentation:** http://localhost:8000/docs
- **Admin Dashboard:** http://localhost:3000/admin/login
  - Email: `admin@vrindopnishad.com`
  - Password: `admin123`

---

## Troubleshooting

### 1. Port Already in Use

If you get "Address already in use" error:

**Backend (change port):**
```bash
python -m uvicorn server:app --port 9000 --reload
```

**Frontend (change port):**
```bash
# macOS/Linux
PORT=3001 yarn start

# Windows
set PORT=3001 && npm start
```

Then update `.env` with the new backend URL.

### 2. Firebase Credentials Error

**Error:** `FileNotFoundError: firebase-credentials.json`

**Solution:**
1. Download the key again from Firebase Console
2. Place it in `backend/` directory
3. Verify the exact filename: `firebase-credentials.json`
4. Check file permissions: `chmod 600 backend/firebase-credentials.json`

### 3. CORS Errors

**Error:** `CORS policy: blocked by CORS`

**Solution:**
1. Update `CORS_ORIGINS` in `backend/.env`
2. Add your frontend URL
3. Example: `CORS_ORIGINS=http://localhost:3000,https://myapp.com`
4. Restart backend server

### 4. Connection Refused

**Error:** `ERROR: HTTPConnectionPool refused: Cannot connect to host`

**Solution:**
1. Make sure backend is running (should see `Uvicorn running` message)
2. Check that frontend `.env` has correct backend URL
3. Verify both are on correct ports (backend:8000, frontend:3000)

### 5. Database Connection Issues

**Error:** `Firebase not initialized` or `Connection timeout`

**Solution:**
1. Verify Firebase project exists in Firebase Console
2. Check `FIREBASE_PROJECT_ID` matches your project
3. Verify storage bucket name is correct
4. Check service account key is valid (not expired)
5. Ensure Firestore and Storage are enabled in Firebase

### 6. Python Virtual Environment Issues

**Windows - venv not activating:**
```bash
# Try this instead:
venv\Scripts\activate.bat
```

**macOS/Linux - permission denied:**
```bash
chmod +x venv/bin/activate
source venv/bin/activate
```

### 7. Dependencies Not Installing

**For Frontend:**
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

**For Backend:**
```bash
cd backend
source venv/bin/activate  # macOS/Linux
pip install --upgrade pip
pip install -r requirements.txt
```

### 8. Can't Login to Admin

Default credentials:
- Email: `admin@vrindopnishad.com`
- Password: `admin123`

To change, edit `backend/.env`:
```env
ADMIN_EMAIL=youremail@example.com
ADMIN_PASSWORD=yourpassword
```

Then restart backend.

---

## File Structure

```
Sant-Vaani/
├── frontend/                    # React web application
│   ├── public/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   │   ├── api.js          # API communication
│   │   │   ├── mockData.js     # Demo mode data
│   │   ├── App.js
│   │   └── index.js
│   ├── package.json
│   ├── .env.example
│   └── .env
│
├── backend/                     # FastAPI server
│   ├── server.py               # Main application
│   ├── requirements.txt        # Python dependencies
│   ├── firebase-credentials.json # Firebase key
│   ├── .env.example
│   └── .env
│
├── tests/                       # Test suite
│
├── QUICK_START.md              # Quick setup guide
├── INSTALLATION.md             # This file
├── FIREBASE_SETUP_GUIDE.md     # Detailed Firebase guide
├── setup.sh                    # Automated setup script
├── start-demo.sh               # Start demo mode
└── start-full.sh               # Start full app

```

---

## Next Steps

### 1. Add Content
After login to admin dashboard:
- Click "Create New Content"
- Fill in Sanskrit, Hindi, English text
- Select category (Shloka, Strotra, Poem)
- Upload or generate images/audio

### 2. Customize
- Change colors: Edit `frontend/src/App.css`
- Change admin password: Edit `backend/.env`
- Add your own Firebase project details

### 3. Deploy to Production

**Frontend:**
- Deploy to Vercel, Netlify, or GitHub Pages
- Update `REACT_APP_BACKEND_URL` to your backend URL

**Backend:**
- Deploy to Railway, Render, Fly.io, or Google Cloud Run
- Update `.env` with production values
- Update `CORS_ORIGINS` to include your domain

---

## Support & Resources

- **Firebase Docs:** https://firebase.google.com/docs
- **FastAPI Docs:** https://fastapi.tiangolo.com
- **React Docs:** https://react.dev
- **See detailed guides:** `FIREBASE_SETUP_GUIDE.md`, `QUICK_START.md`

---

**Happy building! 🙏**

For issues, check the logs in your terminal. Most problems are related to Firebase configuration.
