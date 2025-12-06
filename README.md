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

### Admin Features
- **Secure Admin Login** with JWT authentication
- **Content Management** - Create, Edit, Delete content
- **Multiple Text Formats** - Sanskrit, Hindi, English transliteration, and translation
- **AI Audio Generation** using Google Cloud Text-to-Speech
- **AI Image Generation** using Gemini Nano Banana
- **File Uploads** - Upload audio, images, and videos
- **Firebase Storage** - Secure cloud storage for all media

## 🛠️ Tech Stack

**Frontend**: React 19 | React Router | Axios | CSS3  
**Backend**: FastAPI | Firebase | Google Cloud TTS | Gemini AI  
**Database**: Firebase Firestore | Firebase Storage

## 📦 Quick Start

### 1. Firebase Setup (Required)

Follow the detailed guide in `FIREBASE_SETUP_GUIDE.md`:
1. Create Firebase project
2. Enable Firestore & Storage
3. Download service account JSON
4. Update `/app/backend/.env` with your Firebase config

### 2. Access the Application

- **Website**: https://modern-icons-1.preview.emergentagent.com
- **Admin Login**: `/admin/login`
  - Email: `admin@vrindopnishad.com`
  - Password: `admin123`

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
