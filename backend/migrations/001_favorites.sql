-- Vrindopnishad Database Migrations
-- Run these in Supabase SQL Editor

-- ============================================
-- 1. Create Favorites Table
-- ============================================

CREATE TABLE IF NOT EXISTS favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  content_id UUID REFERENCES content(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, content_id)
);

-- Enable Row Level Security
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own favorites
CREATE POLICY "Users can view own favorites" ON favorites
  FOR SELECT USING (auth.uid() = user_id);

-- Policy: Users can insert their own favorites
CREATE POLICY "Users can insert own favorites" ON favorites
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own favorites
CREATE POLICY "Users can delete own favorites" ON favorites
  FOR DELETE USING (auth.uid() = user_id);


-- ============================================
-- 2. Add Audio URL to Content Table (if not exists)
-- ============================================

DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'content' AND column_name = 'audio_url'
  ) THEN
    ALTER TABLE content ADD COLUMN audio_url TEXT;
  END IF;
END $$;


-- ============================================
-- 3. Add View Count to Content Table (if not exists)
-- ============================================

DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'content' AND column_name = 'view_count'
  ) THEN
    ALTER TABLE content ADD COLUMN view_count INTEGER DEFAULT 0;
  END IF;
END $$;


-- ============================================
-- 4. Create Index for Faster Queries
-- ============================================

CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_content_id ON favorites(content_id);
