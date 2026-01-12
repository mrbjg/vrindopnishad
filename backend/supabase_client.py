"""
Supabase Database Client for Vrindopnishad Backend
Replaces Firebase Firestore with Supabase PostgreSQL
"""
import os
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client, Client
from datetime import datetime, timezone
from typing import Optional, List, Dict, Any
import logging

# Load environment variables from .env file
ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

logger = logging.getLogger(__name__)

# Supabase Configuration
SUPABASE_URL = os.environ.get('SUPABASE_URL', '')
SUPABASE_KEY = os.environ.get('SUPABASE_SERVICE_ROLE_KEY') or os.environ.get('SUPABASE_ANON_KEY', '')

# Global Supabase client
_supabase_client: Optional[Client] = None


def get_supabase_client() -> Optional[Client]:
    """Get or create Supabase client"""
    global _supabase_client
    
    if _supabase_client is not None:
        return _supabase_client
    
    if not SUPABASE_URL or not SUPABASE_KEY:
        logger.warning("Supabase credentials not configured")
        return None
    
    try:
        _supabase_client = create_client(SUPABASE_URL, SUPABASE_KEY)
        logger.info("Supabase client initialized successfully")
        return _supabase_client
    except Exception as e:
        logger.error(f"Failed to initialize Supabase client: {e}")
        return None

class SupabaseDB:
    """Database operations using Supabase"""
    
    def __init__(self):
        self.client = get_supabase_client()
        self.table_name = "content"
    
    @property
    def is_available(self) -> bool:
        return self.client is not None
    
    def create_content(self, content_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create new content"""
        if not self.is_available:
            raise Exception("Supabase not initialized")
        
        content_data['created_at'] = datetime.now(timezone.utc).isoformat()
        content_data['updated_at'] = datetime.now(timezone.utc).isoformat()
        
        response = self.client.table(self.table_name).insert(content_data).execute()
        return response.data[0] if response.data else {}
    
    def update_content(self, content_id: str, update_data: Dict[str, Any]) -> Dict[str, Any]:
        """Update existing content"""
        if not self.is_available:
            raise Exception("Supabase not initialized")
        
        update_data['updated_at'] = datetime.now(timezone.utc).isoformat()
        
        response = self.client.table(self.table_name).update(update_data).eq('id', content_id).execute()
        return response.data[0] if response.data else {}
    
    def delete_content(self, content_id: str) -> bool:
        """Delete content by ID"""
        if not self.is_available:
            raise Exception("Supabase not initialized")
        
        self.client.table(self.table_name).delete().eq('id', content_id).execute()
        return True
    
    def get_content_by_id(self, content_id: str) -> Optional[Dict[str, Any]]:
        """Get single content by ID"""
        if not self.is_available:
            raise Exception("Supabase not initialized")
        
        response = self.client.table(self.table_name).select("*").eq('id', content_id).execute()
        return response.data[0] if response.data else None
    
    def get_all_content(self, category: Optional[str] = None, limit: int = 50) -> List[Dict[str, Any]]:
        """Get all content with optional filtering"""
        if not self.is_available:
            return []
        
        query = self.client.table(self.table_name).select("*").limit(limit)
        
        if category:
            query = query.eq('category', category)
        
        response = query.execute()
        return response.data if response.data else []

    def upload_file(self, bucket: str, path: str, file_bytes: bytes, content_type: str) -> str:
        """Upload file to Supabase Storage and return public URL"""
        if not self.is_available:
            raise Exception("Supabase not initialized")
        
        # Upload file
        self.client.storage.from_(bucket).upload(
            path=path,
            file=file_bytes,
            file_options={"content-type": content_type}
        )
        
        # Get public URL
        public_url = self.client.storage.from_(bucket).get_public_url(path)
        return public_url

# SQL to create the content table in Supabase
CREATE_TABLE_SQL = """
-- Run this in Supabase SQL Editor to create or update the content table

CREATE TABLE IF NOT EXISTS content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    sanskrit_text TEXT,
    hindi_text TEXT,
    english_text TEXT,
    english_translation TEXT,
    category TEXT NOT NULL,
    description TEXT,
    content_text TEXT,
    tags TEXT[] DEFAULT '{}',
    status TEXT DEFAULT 'published',
    author TEXT,
    media_links JSONB DEFAULT '[]',
    audio_url TEXT,
    image_urls TEXT[] DEFAULT '{}',
    video_urls TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- If table already exists, run these to add missing columns:
-- ALTER TABLE content ADD COLUMN IF NOT EXISTS content_text TEXT;
-- ALTER TABLE content ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}';
-- ALTER TABLE content ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'published';
-- ALTER TABLE content ADD COLUMN IF NOT EXISTS author TEXT;
-- ALTER TABLE content ADD COLUMN IF NOT EXISTS media_links JSONB DEFAULT '[]';

-- Enable Row Level Security
ALTER TABLE content ENABLE ROW LEVEL SECURITY;

-- Policy: Allow public read access
CREATE POLICY "Allow public read" ON content
    FOR SELECT USING (true);

-- Policy: Allow authenticated users to insert/update/delete
CREATE POLICY "Allow authenticated write" ON content
    FOR ALL USING (auth.role() = 'authenticated');

-- Create index for faster category filtering
CREATE INDEX IF NOT EXISTS idx_content_category ON content(category);
"""


def test_supabase_connection() -> bool:
    """Test Supabase connection"""
    client = get_supabase_client()
    if not client:
        print("Supabase not configured")
        return False
    
    try:
        # Try to query the content table
        response = client.table("content").select("id").limit(1).execute()
        print(f"Supabase connection successful! Found {len(response.data)} records")
        return True
    except Exception as e:
        print(f"Supabase connection failed: {e}")
        return False


if __name__ == "__main__":
    # Test the connection
    test_supabase_connection()
