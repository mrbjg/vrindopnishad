-- Relational Database Schema and Indexing for VrindaVaani
-- Paste and run this SQL in your Supabase SQL Editor

-- 1. Create Lookup tables

-- Tags (Saints, Books, and general tags)
CREATE TABLE IF NOT EXISTS tags (
    tag_id TEXT PRIMARY KEY,
    _id TEXT UNIQUE,
    name TEXT NOT NULL,
    name_hindi TEXT,
    info TEXT,
    info_hindi TEXT,
    type TEXT DEFAULT 'general', -- 'saint', 'book', 'general'
    active BOOLEAN DEFAULT true,
    priority TEXT,
    facebook_id TEXT,
    biography_id TEXT,
    book_linked_id TEXT,
    chapter_name_eng TEXT,
    chapter_name_hindi TEXT,
    chapter_no TEXT,
    saint_linked_id TEXT REFERENCES tags(tag_id),
    lang TEXT,
    total_verses TEXT,
    photos TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Places (Govardhan, Barsana, Nandgaon, etc.)
CREATE TABLE IF NOT EXISTS places (
    place_id TEXT PRIMARY KEY,
    _id TEXT UNIQUE,
    name TEXT NOT NULL,
    name_hindi TEXT,
    info TEXT,
    info_hindi TEXT,
    active BOOLEAN DEFAULT true,
    priority TEXT,
    facebook_id TEXT,
    path TEXT,
    type TEXT,
    latitude TEXT,
    longitude TEXT,
    videos TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Albums
CREATE TABLE IF NOT EXISTS albums (
    album_id TEXT PRIMARY KEY,
    _id TEXT UNIQUE,
    name TEXT NOT NULL,
    name_hindi TEXT,
    info TEXT,
    info_hindi TEXT,
    active BOOLEAN DEFAULT true,
    priority TEXT,
    facebook_id TEXT,
    path TEXT,
    type TEXT,
    places TEXT[] DEFAULT '{}',
    videos TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Raags
CREATE TABLE IF NOT EXISTS raags (
    raag_id TEXT PRIMARY KEY,
    _id TEXT UNIQUE,
    name TEXT NOT NULL,
    name_hindi TEXT,
    info TEXT,
    info_hindi TEXT,
    active BOOLEAN DEFAULT true,
    priority TEXT,
    facebook_id TEXT,
    type TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subjects
CREATE TABLE IF NOT EXISTS subjects (
    subject_id TEXT PRIMARY KEY,
    _id TEXT UNIQUE,
    name TEXT NOT NULL,
    name_hindi TEXT,
    info TEXT,
    info_hindi TEXT,
    active BOOLEAN DEFAULT true,
    priority TEXT,
    facebook_id TEXT,
    type TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Glossary
CREATE TABLE IF NOT EXISTS glossarys (
    glossary_id TEXT PRIMARY KEY,
    _id TEXT UNIQUE,
    name TEXT NOT NULL,
    name_hindi TEXT,
    info TEXT,
    info_hindi TEXT,
    active BOOLEAN DEFAULT true,
    priority TEXT,
    facebook_id TEXT,
    type TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Medias (Attached to albums)
CREATE TABLE IF NOT EXISTS medias (
    media_id TEXT PRIMARY KEY,
    album_id TEXT REFERENCES albums(album_id),
    name TEXT,
    name_hindi TEXT,
    priority TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create Junction tables for Content (Articles) Many-to-Many Relationships

-- Content to Tags
CREATE TABLE IF NOT EXISTS article_tags (
    content_id UUID REFERENCES content(id) ON DELETE CASCADE,
    tag_id TEXT REFERENCES tags(tag_id) ON DELETE CASCADE,
    PRIMARY KEY (content_id, tag_id)
);

-- Content to Places
CREATE TABLE IF NOT EXISTS article_places (
    content_id UUID REFERENCES content(id) ON DELETE CASCADE,
    place_id TEXT REFERENCES places(place_id) ON DELETE CASCADE,
    PRIMARY KEY (content_id, place_id)
);

-- Content to Raags
CREATE TABLE IF NOT EXISTS article_raags (
    content_id UUID REFERENCES content(id) ON DELETE CASCADE,
    raag_id TEXT REFERENCES raags(raag_id) ON DELETE CASCADE,
    PRIMARY KEY (content_id, raag_id)
);

-- Content to Subjects
CREATE TABLE IF NOT EXISTS article_subjects (
    content_id UUID REFERENCES content(id) ON DELETE CASCADE,
    subject_id TEXT REFERENCES subjects(subject_id) ON DELETE CASCADE,
    PRIMARY KEY (content_id, subject_id)
);

-- Content to Medias
CREATE TABLE IF NOT EXISTS article_medias (
    content_id UUID REFERENCES content(id) ON DELETE CASCADE,
    media_id TEXT REFERENCES medias(media_id) ON DELETE CASCADE,
    PRIMARY KEY (content_id, media_id)
);


-- 3. Create Indexes for Low Cost & High Performance Queries

-- Content Indexes
CREATE INDEX IF NOT EXISTS idx_content_slug ON content(slug);
CREATE INDEX IF NOT EXISTS idx_content_updated_at ON content(updated_at);

-- Lookup Table type/parent Indexes
CREATE INDEX IF NOT EXISTS idx_tags_type ON tags(type);
CREATE INDEX IF NOT EXISTS idx_tags_saint_linked_id ON tags(saint_linked_id);
CREATE INDEX IF NOT EXISTS idx_medias_album_id ON medias(album_id);

-- Junction Table Reverse Indexes (Optimizes selecting content by tag/place/etc.)
CREATE INDEX IF NOT EXISTS idx_article_tags_tag ON article_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_article_places_place ON article_places(place_id);
CREATE INDEX IF NOT EXISTS idx_article_raags_raag ON article_raags(raag_id);
CREATE INDEX IF NOT EXISTS idx_article_subjects_subject ON article_subjects(subject_id);
CREATE INDEX IF NOT EXISTS idx_article_medias_media ON article_medias(media_id);


-- 4. Enable Row Level Security (RLS) on new tables
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE places ENABLE ROW LEVEL SECURITY;
ALTER TABLE albums ENABLE ROW LEVEL SECURITY;
ALTER TABLE raags ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE glossarys ENABLE ROW LEVEL SECURITY;
ALTER TABLE medias ENABLE ROW LEVEL SECURITY;
ALTER TABLE article_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE article_places ENABLE ROW LEVEL SECURITY;
ALTER TABLE article_raags ENABLE ROW LEVEL SECURITY;
ALTER TABLE article_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE article_medias ENABLE ROW LEVEL SECURITY;

-- 5. Create RLS Policies for Public Read & Authenticated Write

-- Tags policies
CREATE POLICY "Allow public read tags" ON tags FOR SELECT USING (true);
CREATE POLICY "Allow auth write tags" ON tags FOR ALL USING (auth.role() = 'authenticated');

-- Places policies
CREATE POLICY "Allow public read places" ON places FOR SELECT USING (true);
CREATE POLICY "Allow auth write places" ON places FOR ALL USING (auth.role() = 'authenticated');

-- Albums policies
CREATE POLICY "Allow public read albums" ON albums FOR SELECT USING (true);
CREATE POLICY "Allow auth write albums" ON albums FOR ALL USING (auth.role() = 'authenticated');

-- Raags policies
CREATE POLICY "Allow public read raags" ON raags FOR SELECT USING (true);
CREATE POLICY "Allow auth write raags" ON raags FOR ALL USING (auth.role() = 'authenticated');

-- Subjects policies
CREATE POLICY "Allow public read subjects" ON subjects FOR SELECT USING (true);
CREATE POLICY "Allow auth write subjects" ON subjects FOR ALL USING (auth.role() = 'authenticated');

-- Glossarys policies
CREATE POLICY "Allow public read glossarys" ON glossarys FOR SELECT USING (true);
CREATE POLICY "Allow auth write glossarys" ON glossarys FOR ALL USING (auth.role() = 'authenticated');

-- Medias policies
CREATE POLICY "Allow public read medias" ON medias FOR SELECT USING (true);
CREATE POLICY "Allow auth write medias" ON medias FOR ALL USING (auth.role() = 'authenticated');

-- Junction tables policies
CREATE POLICY "Allow public read article_tags" ON article_tags FOR SELECT USING (true);
CREATE POLICY "Allow auth write article_tags" ON article_tags FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow public read article_places" ON article_places FOR SELECT USING (true);
CREATE POLICY "Allow auth write article_places" ON article_places FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow public read article_raags" ON article_raags FOR SELECT USING (true);
CREATE POLICY "Allow auth write article_raags" ON article_raags FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow public read article_subjects" ON article_subjects FOR SELECT USING (true);
CREATE POLICY "Allow auth write article_subjects" ON article_subjects FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow public read article_medias" ON article_medias FOR SELECT USING (true);
CREATE POLICY "Allow auth write article_medias" ON article_medias FOR ALL USING (auth.role() = 'authenticated');
