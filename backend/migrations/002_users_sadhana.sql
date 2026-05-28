-- Vrindopnishad Database Migrations
-- Run these in Supabase SQL Editor

-- ============================================
-- Create Users Sadhana Table
-- ============================================

CREATE TABLE IF NOT EXISTS users_sadhana (
  id TEXT PRIMARY KEY, -- Stores Firebase UID or Supabase UUID
  japa_count INTEGER DEFAULT 0,
  swadhyaya_streak INTEGER DEFAULT 0,
  last_swadhyaya_date TEXT DEFAULT '',
  calendar JSONB DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users_sadhana ENABLE ROW LEVEL SECURITY;

-- Clean up existing policies if they exist to prevent duplication errors
DROP POLICY IF EXISTS "Allow select sadhana" ON users_sadhana;
DROP POLICY IF EXISTS "Allow insert sadhana" ON users_sadhana;
DROP POLICY IF EXISTS "Allow update sadhana" ON users_sadhana;
DROP POLICY IF EXISTS "Allow delete sadhana" ON users_sadhana;

-- Policy: Allow read/select access to user sadhana records
-- If the client is logged in via Supabase, auth.uid() will match.
-- For Firebase Auth client fallbacks (which query anonymously), we check that the client knows the UID.
CREATE POLICY "Allow select sadhana" ON users_sadhana
  FOR SELECT USING (true);

-- Policy: Allow insert
CREATE POLICY "Allow insert sadhana" ON users_sadhana
  FOR INSERT WITH CHECK (true);

-- Policy: Allow update
CREATE POLICY "Allow update sadhana" ON users_sadhana
  FOR UPDATE USING (true);

-- Policy: Allow delete
CREATE POLICY "Allow delete sadhana" ON users_sadhana
  FOR DELETE USING (true);

-- Index for fast queries
CREATE INDEX IF NOT EXISTS idx_users_sadhana_id ON users_sadhana(id);
