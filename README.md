# Vrindopnishad - Hindu Vaidik Sanskriti Content Management System

A beautiful, full-stack web application for managing and sharing sacred Hindu texts including Shlokas, Strotras, and devotional poetry. Built with React, FastAPI, Firebase, and powered by AI for audio narration and image generation.

## 🌟 Features

### Public Features
- **Beautiful Vedic-themed UI** with traditional colors and elegant typography
- **Browse Content** by categories: Shlokas, Strotras, Poems
- **Read Sacred Texts** in Sanskrit, Hindi, and English
- **Listen to Audio** narrations with AI-generated or uploaded audio
- **View Imagery** with AI-generated or uploaded images and videos
- **Responsive Design** works on desktop, tablet, and mobile
- **Demo Mode** - Try without any setup required!

### Admin Features
- **Secure Admin Login** with JWT authentication
- **Content Management** - Create, Edit, Delete content
- **Multiple Text Formats** - Sanskrit, Hindi, English transliteration, and translation
- **AI Audio Generation** using Google Cloud Text-to-Speech
- **AI Image Generation** using Gemini Nano Banana
- **File Uploads** - Upload audio, images, and videos
- **Firebase Storage** - Secure cloud storage for all media

## 🛠️ Tech Stack

**Frontend**: React 19 | React Router | Axios | Tailwind CSS  
**Backend**: FastAPI | Firebase | Google Cloud TTS | Gemini AI  
**Database**: Firebase Firestore | Firebase Storage

---

## ⚡ Quick Start (Choose One)

### Option 1: Try Demo Mode (5 minutes) ⭐ **RECOMMENDED**

**No Firebase, no setup, no credentials needed!**

**macOS/Linux:**
```bash
cd Sant-Vaani
chmod +x start-demo.sh
./start-demo.sh
```

**Windows:**
```bash
cd Sant-Vaani\frontend
npm install
npm start
```

Opens at `http://localhost:3000` with sample content to explore.

---

### Option 2: Full Setup with Firebase (15 minutes)

**macOS/Linux:**
```bash
cd Sant-Vaani
chmod +x setup.sh
./setup.sh
# Follow the prompts and instructions
```

**Windows:**
See `INSTALLATION.md` for detailed Windows setup.

---

## 📖 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Quick setup guide for all options
- **[INSTALLATION.md](INSTALLATION.md)** - Detailed installation guide (recommended)
- **[FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md)** - Step-by-step Firebase configuration

---

## 🎯 Getting Started

### 1. Demo Mode (Fastest)
```bash
./start-demo.sh
```
Perfect for testing the UI without any setup.

### 2. Full Setup
1. Follow `INSTALLATION.md`
2. Configure Firebase (5 min)
3. Run backend and frontend
4. Login with `admin@vrindopnishad.com` / `admin123`

### 3. Create Content

1. Login to admin dashboard
2. Click "Create New Content"
3. Add Sanskrit, Hindi, English text
4. Generate AI audio/images or upload files
5. Content appears on public pages

## 🎨 Design Highlights

- **Colors**: Saffron, Gold, Deep Maroon on warm cream background
- **Fonts**: Playfair Display, Cormorant Garamond, Inter
- **Sacred Symbol**: ॐ (Om) in branding
- **Responsive**: Works on all devices

## 📚 Key Endpoints

**Public**:
- `GET /api/content` - List content
- `GET /api/content/{id}` - Get single content

**Admin** (requires JWT token):
- `POST /api/content` - Create content
- `POST /api/content/{id}/generate-audio` - AI audio
- `POST /api/content/{id}/generate-image` - AI image
- `POST /api/upload/{type}/{id}` - Upload files

## 🔒 Security

- JWT authentication for admin
- Firebase security rules
- Environment variables for secrets
- HTTPS enabled

**⚠️ Change default admin password in production!**

## 🐛 Troubleshooting

**Firebase errors**: Check `FIREBASE_SETUP_GUIDE.md`  
**Backend logs**: `tail -f /var/log/supervisor/backend.err.log`  
**Frontend logs**: `tail -f /var/log/supervisor/frontend.err.log`

**Restart services**:
```bash
sudo supervisorctl restart backend
sudo supervisorctl restart frontend
```

## 📖 Documentation

- **Firebase Setup**: See `FIREBASE_SETUP_GUIDE.md`
- **API Docs**: FastAPI auto-docs at `/docs`
- **Content Structure**: Defined in Firestore collections

## 🙏 Built With

Traditional Hindu wisdom meets modern technology to preserve and share sacred texts.

**Om Shanti** 🕉️

---

For detailed documentation, see `FIREBASE_SETUP_GUIDE.md`
