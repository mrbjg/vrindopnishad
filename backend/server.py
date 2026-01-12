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
import firebase_admin
from firebase_admin import credentials, firestore, storage
from google.cloud import texttospeech
import base64
import asyncio

# Optional import for AI image generation
try:
    from emergentintegrations.llm.chat import LlmChat, UserMessage
    HAS_EMERGENT = True
except ImportError:
    HAS_EMERGENT = False
    logging.warning("emergentintegrations not available - AI image generation disabled")


ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# Initialize Firebase
try:
    cred_path = os.environ.get('FIREBASE_CREDENTIALS_PATH', 'firebase-credentials.json')
    if os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred, {
            'storageBucket': os.environ.get('FIREBASE_STORAGE_BUCKET', 'your-project.appspot.com')
        })
        db = firestore.client()
        bucket = storage.bucket()
    else:
        db = None
        bucket = None
        logging.warning("Firebase credentials not found. Using placeholder mode.")
except Exception as e:
    logging.error(f"Firebase initialization failed: {e}")
    db = None
    bucket = None

# Google TTS Client (optional - requires Google Cloud credentials)
try:
    tts_client = texttospeech.TextToSpeechClient()
except Exception as e:
    tts_client = None
    logging.warning(f"Google TTS not available: {e}")

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

# Create the main app
app = FastAPI(title="Vrindopnishad API")
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

class GenerateAudioRequest(BaseModel):
    text: str
    language: str = "hi-IN"  # hi-IN for Hindi, en-IN for English

class GenerateImageRequest(BaseModel):
    prompt: str


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
    if not db:
        raise HTTPException(status_code=503, detail="Firebase not initialized. Please configure Firebase credentials.")
    
    try:
        content_id = str(uuid.uuid4())
        content_data = content.model_dump()
        content_data.update({
            "id": content_id,
            "created_at": datetime.now(timezone.utc).isoformat(),
            "updated_at": datetime.now(timezone.utc).isoformat()
        })
        
        # Ensure audio_url, image_urls, video_urls lists exist if not provided
        if "audio_url" not in content_data:
            content_data["audio_url"] = None
        if "image_urls" not in content_data:
            content_data["image_urls"] = []
        if "video_urls" not in content_data:
            content_data["video_urls"] = []
            
        db.collection('content').document(content_id).set(content_data)
        return {"success": True, "id": content_id, "message": "Content created successfully"}
    except Exception as e:
        logger.error(f"Error creating content: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.put("/content/{content_id}")
async def update_content(content_id: str, content: ContentUpdate, payload: dict = Depends(verify_token)):
    """Update content (Admin only)"""
    if not db:
        raise HTTPException(status_code=503, detail="Firebase not initialized")
    
    try:
        content_ref = db.collection('content').document(content_id)
        if not content_ref.get().exists:
            raise HTTPException(status_code=404, detail="Content not found")
        
        update_data = {k: v for k, v in content.model_dump().items() if v is not None}
        update_data["updated_at"] = datetime.now(timezone.utc).isoformat()
        
        content_ref.update(update_data)
        return {"success": True, "message": "Content updated successfully"}
    except Exception as e:
        logger.error(f"Error updating content: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.delete("/content/{content_id}")
async def delete_content(content_id: str, payload: dict = Depends(verify_token)):
    """Delete content (Admin only)"""
    if not db:
        raise HTTPException(status_code=503, detail="Firebase not initialized")
    
    try:
        db.collection('content').document(content_id).delete()
        return {"success": True, "message": "Content deleted successfully"}
    except Exception as e:
        logger.error(f"Error deleting content: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# AI Generation Routes (Admin)
@api_router.post("/content/{content_id}/generate-audio")
async def generate_audio(content_id: str, request: GenerateAudioRequest, payload: dict = Depends(verify_token)):
    """Generate audio using Google TTS"""
    if not tts_client:
        raise HTTPException(status_code=503, detail="Google TTS not available - missing credentials")
    
    if not db:
        raise HTTPException(status_code=503, detail="Firebase not initialized")
    
    try:
        # Synthesize speech
        synthesis_input = texttospeech.SynthesisInput(text=request.text)
        voice = texttospeech.VoiceSelectionParams(
            language_code=request.language,
            ssml_gender=texttospeech.SsmlVoiceGender.NEUTRAL
        )
        audio_config = texttospeech.AudioConfig(
            audio_encoding=texttospeech.AudioEncoding.MP3
        )
        
        response = tts_client.synthesize_speech(
            input=synthesis_input,
            voice=voice,
            audio_config=audio_config
        )
        
        # Upload to Firebase Storage
        if bucket:
            blob_name = f"audio/{content_id}_{uuid.uuid4()}.mp3"
            blob = bucket.blob(blob_name)
            blob.upload_from_string(response.audio_content, content_type='audio/mpeg')
            blob.make_public()
            audio_url = blob.public_url
            
            # Update content with audio URL
            db.collection('content').document(content_id).update({"audio_url": audio_url})
            
            return {"success": True, "audio_url": audio_url}
        else:
            return {"success": False, "message": "Firebase Storage not available"}
    except Exception as e:
        logger.error(f"Error generating audio: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.post("/content/{content_id}/generate-image")
async def generate_image(content_id: str, request: GenerateImageRequest, payload: dict = Depends(verify_token)):
    """Generate image using Gemini Nano Banana"""
    if not HAS_EMERGENT:
        raise HTTPException(status_code=503, detail="AI image generation not available - emergentintegrations package not installed")
    
    if not db:
        raise HTTPException(status_code=503, detail="Firebase not initialized")
    
    try:
        api_key = os.getenv("EMERGENT_LLM_KEY")
        chat = LlmChat(api_key=api_key, session_id=f"image-gen-{uuid.uuid4()}", system_message="You are a helpful AI assistant")
        chat.with_model("gemini", "gemini-2.5-flash-image-preview").with_params(modalities=["image", "text"])
        
        msg = UserMessage(text=request.prompt)
        text, images = await chat.send_message_multimodal_response(msg)
        
        if images and bucket:
            image_urls = []
            for idx, img in enumerate(images):
                # Upload to Firebase Storage
                blob_name = f"images/{content_id}_{uuid.uuid4()}.png"
                blob = bucket.blob(blob_name)
                image_bytes = base64.b64decode(img['data'])
                blob.upload_from_string(image_bytes, content_type=img['mime_type'])
                blob.make_public()
                image_urls.append(blob.public_url)
            
            # Update content with image URLs
            content_ref = db.collection('content').document(content_id)
            content_doc = content_ref.get()
            if content_doc.exists:
                existing_images = content_doc.to_dict().get('image_urls', [])
                existing_images.extend(image_urls)
                content_ref.update({"image_urls": existing_images})
            
            return {"success": True, "image_urls": image_urls}
        else:
            return {"success": False, "message": "No images generated or Firebase Storage not available"}
    except Exception as e:
        logger.error(f"Error generating image: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# File Upload Routes (Admin)
@api_router.post("/upload/audio/{content_id}")
async def upload_audio(content_id: str, file: UploadFile = File(...), payload: dict = Depends(verify_token)):
    """Upload audio file"""
    if not db or not bucket:
        raise HTTPException(status_code=503, detail="Firebase not initialized")
    
    try:
        contents = await file.read()
        blob_name = f"audio/{content_id}_{uuid.uuid4()}_{file.filename}"
        blob = bucket.blob(blob_name)
        blob.upload_from_string(contents, content_type=file.content_type)
        blob.make_public()
        audio_url = blob.public_url
        
        db.collection('content').document(content_id).update({"audio_url": audio_url})
        
        return {"success": True, "audio_url": audio_url}
    except Exception as e:
        logger.error(f"Error uploading audio: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.post("/upload/image/{content_id}")
async def upload_image(content_id: str, file: UploadFile = File(...), payload: dict = Depends(verify_token)):
    """Upload image file"""
    if not db or not bucket:
        raise HTTPException(status_code=503, detail="Firebase not initialized")
    
    try:
        contents = await file.read()
        blob_name = f"images/{content_id}_{uuid.uuid4()}_{file.filename}"
        blob = bucket.blob(blob_name)
        blob.upload_from_string(contents, content_type=file.content_type)
        blob.make_public()
        image_url = blob.public_url
        
        # Add to image_urls array
        content_ref = db.collection('content').document(content_id)
        content_doc = content_ref.get()
        if content_doc.exists:
            existing_images = content_doc.to_dict().get('image_urls', [])
            existing_images.append(image_url)
            content_ref.update({"image_urls": existing_images})
        
        return {"success": True, "image_url": image_url}
    except Exception as e:
        logger.error(f"Error uploading image: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.post("/upload/video/{content_id}")
async def upload_video(content_id: str, file: UploadFile = File(...), payload: dict = Depends(verify_token)):
    """Upload video file"""
    if not db or not bucket:
        raise HTTPException(status_code=503, detail="Firebase not initialized")
    
    try:
        contents = await file.read()
        blob_name = f"videos/{content_id}_{uuid.uuid4()}_{file.filename}"
        blob = bucket.blob(blob_name)
        blob.upload_from_string(contents, content_type=file.content_type)
        blob.make_public()
        video_url = blob.public_url
        
        # Add to video_urls array
        content_ref = db.collection('content').document(content_id)
        content_doc = content_ref.get()
        if content_doc.exists:
            existing_videos = content_doc.to_dict().get('video_urls', [])
            existing_videos.append(video_url)
            content_ref.update({"video_urls": existing_videos})
        
        return {"success": True, "video_url": video_url}
    except Exception as e:
        logger.error(f"Error uploading video: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# Public Routes
@api_router.get("/content")
async def get_all_content(category: Optional[str] = None, limit: int = 50):
    """Get all content (Public)"""
    if not db:
        # Return mock data for demo
        return {
            "success": True,
            "total": 0,
            "content": [],
            "message": "Firebase not initialized. Please configure Firebase credentials."
        }
    
    try:
        query = db.collection('content')
        if category:
            query = query.where('category', '==', category)
        
        docs = query.limit(limit).stream()
        content_list = [doc.to_dict() for doc in docs]
        
        return {"success": True, "total": len(content_list), "content": content_list}
    except Exception as e:
        logger.error(f"Error fetching content: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.get("/content/{content_id}")
async def get_content_by_id(content_id: str):
    """Get single content by ID (Public)"""
    if not db:
        raise HTTPException(status_code=503, detail="Firebase not initialized")
    
    try:
        doc = db.collection('content').document(content_id).get()
        if not doc.exists:
            raise HTTPException(status_code=404, detail="Content not found")
        
        return {"success": True, "content": doc.to_dict()}
    except Exception as e:
        logger.error(f"Error fetching content: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@api_router.get("/categories")
async def get_categories():
    """Get all categories"""
    if not db:
        return {
            "success": True,
            "categories": [
                {"id": "shloka", "name": "Shlokas"},
                {"id": "strotra", "name": "Strotras"},
                {"id": "poem", "name": "Poems"}
            ]
        }
    
    try:
        # Get unique categories from content collection
        docs = db.collection('content').select(['category']).stream()
        categories = set()
        for doc in docs:
            cat = doc.to_dict().get('category')
            if cat:
                categories.add(cat)
        
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
    return {"message": "Vrindopnishad API", "version": "1.0.0"}


# Include the router in the main app
app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("shutdown")
async def shutdown_event():
    if db:
        firebase_admin.delete_app(firebase_admin.get_app())
