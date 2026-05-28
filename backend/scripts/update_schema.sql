-- Run this SQL in your Supabase SQL Editor to update the content table schema and ensure it is fully unified for both the backend and premium_app

-- Add missing columns to the content table
ALTER TABLE content ADD COLUMN IF NOT EXISTS content_text TEXT;
ALTER TABLE content ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}';
ALTER TABLE content ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'published';
ALTER TABLE content ADD COLUMN IF NOT EXISTS author TEXT;
ALTER TABLE content ADD COLUMN IF NOT EXISTS media_links JSONB DEFAULT '[]';

-- Premium App Specific Columns for full unified database structure
ALTER TABLE content ADD COLUMN IF NOT EXISTS book TEXT;
ALTER TABLE content ADD COLUMN IF NOT EXISTS section TEXT;
ALTER TABLE content ADD COLUMN IF NOT EXISTS chapter TEXT;
ALTER TABLE content ADD COLUMN IF NOT EXISTS heading TEXT;
ALTER TABLE content ADD COLUMN IF NOT EXISTS audio_tags TEXT[] DEFAULT '{}';
ALTER TABLE content ADD COLUMN IF NOT EXISTS video_tags TEXT[] DEFAULT '{}';
ALTER TABLE content ADD COLUMN IF NOT EXISTS image_tags TEXT[] DEFAULT '{}';

-- Verify the table structure
-- SELECT column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'content';
