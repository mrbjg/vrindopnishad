-- Run this SQL in your Supabase SQL Editor to update the content table schema

-- Add missing columns to the content table
ALTER TABLE content ADD COLUMN IF NOT EXISTS content_text TEXT;
ALTER TABLE content ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}';
ALTER TABLE content ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'published';
ALTER TABLE content ADD COLUMN IF NOT EXISTS author TEXT;
ALTER TABLE content ADD COLUMN IF NOT EXISTS media_links JSONB DEFAULT '[]';

-- Verify the table structure
-- SELECT column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'content';
