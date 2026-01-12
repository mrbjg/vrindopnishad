"""
Server with Supabase Support for Vrindopnishad Backend
This is an alternative server configuration that uses Supabase instead of Firebase
"""
from fastapi import FastAPI, APIRouter, Depends, HTTPException, UploadFile, File, Form, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field
from typing import List, Optional
import uuid
from datetime import datetime, timezone, timedelta
import jwt
from passlib.context import CryptContext

# Import Supabase client
from supabase_client import SupabaseDB, get_supabase_client

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# Initialize Supabase
supabase_db = SupabaseDB()
if supabase_db.is_available:
    logging.info("Supabase initialized successfully")
else:
    logging.warning("Supabase not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY in .env")

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

# Create the main app
app = FastAPI(title="Vrindopnishad API (Supabase)")
api_router = APIRouter(prefix="/api")

# JWT Configuration
JWT_SECRET = os.environ.get('JWT_SECRET_KEY', 'vrindopnishad-secret-key')
JWT_ALGORITHM = "HS256"
JWT_EXPIRATION_HOURS = 24

# Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Models
class AdminLogin(BaseModel):
    email: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

class ContentCreate(BaseModel):
    title: str
    sanskrit_text: Optional[str] = None
    hindi_text: Optional[str] = None
    english_text: Optional[str] = None
    english_translation: Optional[str] = None
    category: str
    description: Optional[str] = None
    tags: List[str] = []
    content_text: Optional[str] = None
    status: str = "published"
    author: Optional[str] = None
    media_links: List[dict] = []

class ContentUpdate(BaseModel):
    title: Optional[str] = None
    sanskrit_text: Optional[str] = None
    hindi_text: Optional[str] = None
    english_text: Optional[str] = None
    english_translation: Optional[str] = None
    category: Optional[str] = None
    description: Optional[str] = None
    tags: Optional[List[str]] = None
    content_text: Optional[str] = None
    status: Optional[str] = None
    author: Optional[str] = None
    media_links: Optional[List[dict]] = None


# Helper Functions
def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(hours=JWT_EXPIRATION_HOURS)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, JWT_SECRET, algorithm=JWT_ALGORITHM)
    return encoded_jwt

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        token = credentials.credentials
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token has expired")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")


# Authentication Routes
@api_router.post("/auth/login", response_model=TokenResponse)
async def login(credentials: AdminLogin):
    """Admin login endpoint"""
    admin_email = os.environ.get('ADMIN_EMAIL', 'admin@vrindopnishad.com')
    admin_password = os.environ.get('ADMIN_PASSWORD', 'admin123')
    
    if credentials.email == admin_email and credentials.password == admin_password:
        access_token = create_access_token({"email": credentials.email, "role": "admin"})
        return {"access_token": access_token, "token_type": "bearer"}
    
    raise HTTPException(status_code=401, detail="Invalid credentials")

@api_router.get("/auth/verify")
async def verify(payload: dict = Depends(verify_token)):
    """Verify token validity"""
    return {"valid": True, "email": payload.get("email")}


# Content Management Routes (Admin)
@api_router.post("/content")
async def create_content(content: ContentCreate, payload: dict = Depends(verify_token)):
    """Create new content (Admin only)"""
    if not supabase_db.is_available:
        raise HTTPException(status_code=503, detail="Supabase not initialized. Please configure credentials.")
    
    try:
        content_id = str(uuid.uuid4())
        content_data = content.model_dump()
        content_data.update({
            "id": content_id,
            "audio_url": None,
            "image_urls": [],
            "video_urls": [],
        })
        
        result = supabase_db.create_content(content_data)
        return {"success": True, "id": content_id, "message": "Content created successfully"}
    except Exception as e:
        logger.error(f"Error creating content: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.put("/content/{content_id}")
async def update_content(content_id: str, content: ContentUpdate, payload: dict = Depends(verify_token)):
    """Update content (Admin only)"""
    if not supabase_db.is_available:
        raise HTTPException(status_code=503, detail="Supabase not initialized")
    
    try:
        existing = supabase_db.get_content_by_id(content_id)
        if not existing:
            raise HTTPException(status_code=404, detail="Content not found")
        
        update_data = {k: v for k, v in content.model_dump().items() if v is not None}
        supabase_db.update_content(content_id, update_data)
        return {"success": True, "message": "Content updated successfully"}
    except Exception as e:
        logger.error(f"Error updating content: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.delete("/content/{content_id}")
async def delete_content(content_id: str, payload: dict = Depends(verify_token)):
    """Delete content (Admin only)"""
    if not supabase_db.is_available:
        raise HTTPException(status_code=503, detail="Supabase not initialized")
    
    try:
        supabase_db.delete_content(content_id)
        return {"success": True, "message": "Content deleted successfully"}
    except Exception as e:
        logger.error(f"Error deleting content: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# File Upload Routes (Admin)
@api_router.post("/upload/audio/{content_id}")
async def upload_audio(content_id: str, file: UploadFile = File(...), payload: dict = Depends(verify_token)):
    """Upload audio file to Supabase Storage"""
    if not supabase_db.is_available:
        raise HTTPException(status_code=503, detail="Supabase not initialized")
    
    try:
        # Check if content exists
        content = supabase_db.get_content_by_id(content_id)
        if not content:
            raise HTTPException(status_code=404, detail="Content not found")
        
        # Read file
        file_bytes = await file.read()
        file_ext = os.path.splitext(file.filename)[1]
        file_path = f"{content_id}/audio{file_ext}"
        
        # Upload to Supabase 'audio' bucket
        public_url = supabase_db.upload_file(
            bucket="audio",
            path=file_path,
            file_bytes=file_bytes,
            content_type=file.content_type
        )
        
        # Update content with audio URL
        supabase_db.update_content(content_id, {"audio_url": public_url})
        
        return {"success": True, "audio_url": public_url, "message": "Audio uploaded successfully"}
    except Exception as e:
        logger.error(f"Error uploading audio: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.post("/upload/image/{content_id}")
async def upload_image(content_id: str, file: UploadFile = File(...), payload: dict = Depends(verify_token)):
    """Upload image file to Supabase Storage"""
    if not supabase_db.is_available:
        raise HTTPException(status_code=503, detail="Supabase not initialized")
    
    try:
        # Check if content exists
        content = supabase_db.get_content_by_id(content_id)
        if not content:
            raise HTTPException(status_code=404, detail="Content not found")
        
        # Read file
        file_bytes = await file.read()
        file_ext = os.path.splitext(file.filename)[1]
        timestamp = int(datetime.now().timestamp())
        file_path = f"{content_id}/image_{timestamp}{file_ext}"
        
        # Upload to Supabase 'images' bucket
        public_url = supabase_db.upload_file(
            bucket="images",
            path=file_path,
            file_bytes=file_bytes,
            content_type=file.content_type
        )
        
        # Update content with image URL (append to list)
        current_images = content.get('image_urls', []) or []
        current_images.append(public_url)
        supabase_db.update_content(content_id, {"image_urls": current_images})
        
        return {"success": True, "image_url": public_url, "message": "Image uploaded successfully"}
    except Exception as e:
        logger.error(f"Error uploading image: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Public Routes
@api_router.get("/content")
async def get_all_content(category: Optional[str] = None, limit: int = 50):
    """Get all content (Public)"""
    if not supabase_db.is_available:
        return {
            "success": True,
            "total": 0,
            "content": [],
            "message": "Supabase not initialized. Please configure credentials."
        }
    
    try:
        content_list = supabase_db.get_all_content(category=category, limit=limit)
        return {"success": True, "total": len(content_list), "content": content_list}
    except Exception as e:
        logger.error(f"Error fetching content: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.get("/content/{content_id}")
async def get_content_by_id(content_id: str):
    """Get single content by ID (Public)"""
    if not supabase_db.is_available:
        raise HTTPException(status_code=503, detail="Supabase not initialized")
    
    try:
        content = supabase_db.get_content_by_id(content_id)
        if not content:
            raise HTTPException(status_code=404, detail="Content not found")
        
        return {"success": True, "content": content}
    except Exception as e:
        logger.error(f"Error fetching content: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.get("/categories")
async def get_categories():
    """Get all categories"""
    if not supabase_db.is_available:
         return {
            "success": True,
            "categories": [
                {"id": "shloka", "name": "Shlokas"},
                {"id": "strotra", "name": "Strotras"},
                {"id": "poem", "name": "Poems"}
            ]
        }
    
    try:
        # Get unique categories from content table
        response = supabase_db.client.table(supabase_db.table_name).select("category").execute()
        categories = set()
        for item in response.data:
            cat = item.get('category')
            if cat:
                categories.add(cat)
        
        if not categories:
            return {
                "success": True,
                "categories": [
                    {"id": "shloka", "name": "Shlokas"},
                    {"id": "strotra", "name": "Strotras"},
                    {"id": "poem", "name": "Poems"}
                ]
            }

        return {
            "success": True,
            "categories": [{"id": cat.lower().replace(" ", "-"), "name": cat} for cat in sorted(list(categories))]
        }
    except Exception as e:
        logger.error(f"Error fetching categories: {e}")
        return {
            "success": True,
            "categories": [
                {"id": "shloka", "name": "Shlokas"},
                {"id": "strotra", "name": "Strotras"},
                {"id": "poem", "name": "Poems"}
            ]
        }

@api_router.get("/")
async def root():
    return {"message": "Vrindopnishad API (Supabase)", "version": "1.0.0"}

# Include the router in the main app
app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
