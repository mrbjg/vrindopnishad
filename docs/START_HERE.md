# 🚀 Sant-Vaani - Start Here!

This document will get you up and running in minutes.

## Choose Your Path

### 👉 Path 1: I Just Want to See It Work (Recommended for first-time)

**Time required:** 5 minutes  
**Requirements:** Node.js installed  
**Setup needed:** None!

```bash
cd Sant-Vaani
chmod +x start-demo.sh
./start-demo.sh
```

Then open http://localhost:3000 in your browser.

**What you get:**
- ✅ Full working UI with sample content
- ✅ Can browse categories and read texts
- ✅ Can test admin login (admin@vrindopnishad.com / admin123)
- ✅ No database or credentials needed

---

### 👉 Path 2: I Want Full Features with Database (Firebase)

**Time required:** 15 minutes  
**Requirements:** Node.js, Python, Google account  
**Cost:** Free (Firebase free tier)

#### Step 1: Run Setup Script

```bash
cd Sant-Vaani
chmod +x setup.sh
./setup.sh
```

#### Step 2: Configure Firebase (5 minutes)

1. Go to https://console.firebase.google.com/
2. Create a new project named `vrindopnishad`
3. Enable: Firestore Database, Cloud Storage, Authentication
4. Get your credentials and save as `backend/firebase-credentials.json`
5. Get your storage bucket name

#### Step 3: Edit .env File

Edit `Sant-Vaani/backend/.env`:

```env
FIREBASE_CREDENTIALS_PATH=./firebase-credentials.json
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
ADMIN_EMAIL=admin@vrindopnishad.com
ADMIN_PASSWORD=admin123
JWT_SECRET_KEY=your-secret-key
CORS_ORIGINS=http://localhost:3000
```

#### Step 4: Start Backend

```bash
cd Sant-Vaani/backend
source venv/bin/activate
python -m uvicorn server:app --reload
```

#### Step 5: Start Frontend (new terminal)

```bash
cd Sant-Vaani/frontend
yarn start
```

**Access:**
- Frontend: http://localhost:3000
- API Docs: http://localhost:8000/docs
- Admin: http://localhost:3000/admin/login

---

## 🔧 Troubleshooting

### "Cannot find module 'react'"
```bash
cd frontend
npm install
```

### "Port 3000 already in use"
```bash
PORT=3001 yarn start
```

### "Firebase credentials not found"
1. Download from Firebase Console → Project Settings → Service Accounts
2. Save as `backend/firebase-credentials.json`

### "Cannot connect to backend"
1. Make sure backend is running (Terminal 1)
2. Check `.env` has correct `REACT_APP_BACKEND_URL`
3. Restart frontend

### "ModuleNotFoundError: No module named 'fastapi'"
```bash
cd backend
source venv/bin/activate
pip install -r requirements.txt
```

---

## 📂 Project Structure

```
Sant-Vaani/
├── frontend/          # React web UI
├── backend/           # Python FastAPI server
├── tests/            # Test suite
├── README.md         # Main documentation
├── QUICK_START.md    # Quick setup guide
├── INSTALLATION.md   # Detailed installation
├── start-demo.sh     # Run demo mode
├── start-full.sh     # Run full app
└── setup.sh          # Setup dependencies
```

---

## 🎓 Learn More

- **[INSTALLATION.md](INSTALLATION.md)** - Detailed setup guide
- **[QUICK_START.md](QUICK_START.md)** - All setup options
- **[FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md)** - Firebase configuration

---

## ❓ FAQ

**Q: Do I need Firebase to try the app?**  
A: No! Run `./start-demo.sh` for instant demo mode.

**Q: Can I run just the frontend?**  
A: Yes! `./start-demo.sh` runs just the frontend with sample data.

**Q: What are the default admin credentials?**  
A: Email: `admin@vrindopnishad.com`, Password: `admin123`

**Q: Can I change the admin password?**  
A: Yes, edit `backend/.env` after setting up Firebase.

**Q: Is this free?**  
A: Yes! Uses Firebase's free tier. Hosting is separate cost.

---

## ✨ Next Steps

1. **Try Demo Mode:** `./start-demo.sh`
2. **Set up Firebase:** Follow [INSTALLATION.md](INSTALLATION.md)
3. **Add your content:** Login to admin dashboard
4. **Customize:** Edit colors in `frontend/src/App.css`
5. **Deploy:** Follow deployment guide in INSTALLATION.md

---

**Enjoy! 🙏**
