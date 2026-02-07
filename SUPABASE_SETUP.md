# VrindaVaani - Supabase Integration Setup

## ✅ Setup Complete!

Your VrindaVaani app is now connected to Supabase with **645 dual-language articles** ready to use.

## 📁 Files Created/Updated

### Backend
- `backend/.env` - Supabase credentials and configuration
- `backend/supabase_client.py` - Database client (already existed)
- `backend/server_supabase.py` - API server with Supabase (already existed)

### Frontend
- `frontend/.env` - Supabase URL and API key
- `frontend/src/lib/supabase.js` - Supabase client (already existed)
- `frontend/src/services/api.js` - API service with Supabase (already existed)
- `frontend/src/services/supabaseApi.js` - **NEW** comprehensive API service

### Startup Scripts
- `start-supabase.sh` - Start full application (frontend + backend)
- `start-backend-supabase.sh` - Start backend only

## 🚀 How to Run

### Option 1: Start Full Application (Recommended)
```bash
cd /Users/mr.bajrangi/Code/Company/Projects/VrindaVaani
chmod +x start-supabase.sh
./start-supabase.sh
```

This will start:
- **Backend API** at `http://localhost:8000`
- **Frontend** at `http://localhost:3000`  
- **API Docs** at `http://localhost:8000/docs`

### Option 2: Start Backend Only
```bash
cd /Users/mr.bajrangi/Code/Company/Projects/VrindaVaani
chmod +x start-backend-supabase.sh
./start-backend-supabase.sh
```

### Option 3: Manual Start

**Backend:**
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt python-dotenv supabase
python3 server_supabase.py
```

**Frontend:**
```bash
cd frontend
npm install
npm start
```

## 🔑 Environment Variables

### Backend (`.env` in `backend/` directory)
```env
SUPABASE_URL=https://gawfwpnfsslckbpxejvl.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...
ADMIN_EMAIL=admin@vrindavaani.com
ADMIN_PASSWORD=vrinda123
JWT_SECRET_KEY=vrinda-vaani-secret-jwt-key-2024
```

### Frontend (`.env` in `frontend/` directory)
```env
REACT_APP_SUPABASE_URL=https://gawfwpnfsslckbpxejvl.supabase.co
REACT_APP_SUPABASE_ANON_KEY=eyJhbGc...
REACT_APP_API_URL=http://localhost:8000/api
```

## 📊 Database Info

- **Database**: Supabase PostgreSQL
- **Table**: `content`
- **Records**: 645 dual-language articles from BrajRasik.org
- **Structure**:
  - `id` - UUID primary key
  - `title` - Article title
  - `hindi_text` - Hindi content
  - `english_translation` - English translation
  - `category` - Content category
  - `tags` - Array of tags
  - `description` - Article description
  - `author` - Content author
  - `created_at`, `updated_at` - Timestamps

## 🔐 Admin Access

**Login Credentials:**
- Email: `admin@vrindavaani.com`
- Password: `vrinda123`

**Admin Features:**
- Create/Edit/Delete content
- Upload audio/images/videos
- Manage categories and tags

## 📱 API Endpoints

### Public (No Auth Required)
- `GET /api/content` - List all content
- `GET /api/content/{id}` - Get single content
- `GET /api/categories` - List categories

### Admin (Requires JWT Token)
- `POST /api/auth/login` - Admin login
- `POST /api/content` - Create content
- `PUT /api/content/{id}` - Update content
- `DELETE /api/content/{id}` - Delete content
- `POST /api/upload/audio/{id}` - Upload audio
- `POST /api/upload/image/{id}` - Upload image

## 🧪 Testing Connection

Test if Supabase is connected:
```bash
cd backend
source venv/bin/activate
python3 supabase_client.py
```

Expected output: "Supabase connection successful! Found 645 records"

## 📚 Frontend Usage

The frontend can now query Supabase directly or use the backend API:

```javascript
// Option 1: Direct Supabase (frontend/src/services/api.js)
import { apiService } from './services/api';

const content = await apiService.getAllContent();
const categories = await apiService.getCategories();

// Option 2: Backend API (frontend/src/services/supabaseApi.js)
import api from './services/supabaseApi';

const response = await api.getAllContent();
const content = response.content;
```

## 🎨 Features

✅ Direct Supabase database access  
✅ RESTful API with FastAPI backend  
✅ JWT authentication for admin  
✅ File uploads to Supabase Storage  
✅ 645 dual-language articles ready  
✅ Category filtering  
✅ Search functionality  
✅ Demo mode support  

## 🐛 Troubleshooting

**1. Connection Error**
- Check internet connection
- Verify `.env` files exist in both `backend/` and `frontend/` directories
- Ensure Supabase URL and keys are correct

**2. Import Errors**
```bash
pip install python-dotenv supabase fastapi uvicorn
```

**3. Frontend Errors**
```bash
cd frontend
npm install @supabase/supabase-js
```

**4. Port Already in Use**
- Backend (8000): `lsof -ti:8000 | xargs kill -9`
- Frontend (3000): `lsof -ti:3000 | xargs kill -9`

## 🌐 Deployment

For production:
1. Update Supabase RLS policies
2. Change admin password
3. Update JWT secret
4. Set production URLs in `.env`
5. Build frontend: `npm run build`
6. Deploy backend with Gunicorn/Uvicorn

## 📞 Support

The VrindaVaani app is now fully connected to Supabase!

**Database**: 645 articles ✅  
**Backend API**: Ready ✅  
**Frontend**: Ready ✅  
**Authentication**: Configured ✅  

Happy coding! 🕉️
