-- VrindaVaani Phase 1: Core Data Tables
-- Run this in Supabase SQL Editor

-- 1. Daily Motivations (Level-Based)
CREATE TABLE IF NOT EXISTS daily_motivations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content TEXT NOT NULL,
  source TEXT,
  min_level INT DEFAULT 1,
  max_level INT DEFAULT 99,
  category TEXT DEFAULT 'general',
  language TEXT DEFAULT 'hi',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Daily Gyaan (Wisdom Content)
CREATE TABLE IF NOT EXISTS daily_gyaan (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  media_url TEXT,
  media_type TEXT,
  difficulty INT DEFAULT 1,
  category TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Sacred Calendar (Vrat/Utsav)
CREATE TABLE IF NOT EXISTS sacred_calendar (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  date DATE NOT NULL,
  type TEXT NOT NULL,
  is_recurring BOOLEAN DEFAULT false,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. User Achievements
CREATE TABLE IF NOT EXISTS user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_uid TEXT NOT NULL,
  achievement_id TEXT NOT NULL,
  unlocked_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(firebase_uid, achievement_id)
);

-- 5. Daily Challenges
CREATE TABLE IF NOT EXISTS daily_challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL,
  target_value INT NOT NULL,
  xp_reward INT DEFAULT 100,
  min_level INT DEFAULT 1,
  date DATE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. User Challenge Progress
CREATE TABLE IF NOT EXISTS user_challenge_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_uid TEXT NOT NULL,
  challenge_id UUID REFERENCES daily_challenges(id),
  current_value INT DEFAULT 0,
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(firebase_uid, challenge_id)
);

-- 7. Extend user_stats with new columns
ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS spirituality_level TEXT DEFAULT 'seeker';
ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS daily_mala_goal INT DEFAULT 11;
ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS preferred_language TEXT DEFAULT 'hi';
ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT false;
ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS total_badges INT DEFAULT 0;
ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS reminder_time TEXT;
ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS dynamic_icon_enabled BOOLEAN DEFAULT true;

-- 8. Enable RLS on new tables
ALTER TABLE daily_motivations ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_gyaan ENABLE ROW LEVEL SECURITY;
ALTER TABLE sacred_calendar ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_challenge_progress ENABLE ROW LEVEL SECURITY;

-- Public read for content tables
CREATE POLICY "Public read daily_motivations" ON daily_motivations FOR SELECT USING (true);
CREATE POLICY "Public read daily_gyaan" ON daily_gyaan FOR SELECT USING (true);
CREATE POLICY "Public read sacred_calendar" ON sacred_calendar FOR SELECT USING (true);
CREATE POLICY "Public read daily_challenges" ON daily_challenges FOR SELECT USING (true);

-- User-specific for progress tables
CREATE POLICY "Users manage own achievements" ON user_achievements FOR ALL USING (true);
CREATE POLICY "Users manage own challenge progress" ON user_challenge_progress FOR ALL USING (true);

-- 9. Seed some sample motivations
INSERT INTO daily_motivations (content, source, min_level, max_level, category) VALUES
  ('हरि को भजे सो हरि को होई। माया को भजे सो माया को होई।', 'कबीर दास', 1, 5, 'general'),
  ('जो सुख में सुमिरन करे, तो दुख काहे होय।', 'कबीर दास', 1, 10, 'naam_jap'),
  ('मन के हारे हार है, मन के जीते जीत।', 'संत वाणी', 1, 99, 'general'),
  ('राम नाम की लूट है, लूट सके तो लूट। अंत काल पछतायेगा, जब प्राण जायेंगे छूट।', 'कबीर दास', 1, 15, 'naam_jap'),
  ('गुरू बिन ज्ञान न उपजै, गुरू बिन मिलै न मोक्ष।', 'कबीर दास', 6, 99, 'reading'),
  ('साधो, देखो जग बौराना। साँची कहौं तो मारन धावै, झूठे जग पतियाना।', 'कबीर दास', 16, 99, 'sadhana'),
  ('आत्मा अजर अमर है, ये शरीर नाशवान। इस सत्य को जो जाने, वही सच्चा ज्ञानवान।', 'भगवद् गीता', 6, 30, 'reading'),
  ('कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।', 'भगवद् गीता 2.47', 1, 99, 'general');

-- 10. Seed some sacred calendar events for 2026
INSERT INTO sacred_calendar (title, description, date, type, is_recurring) VALUES
  ('एकादशी व्रत', 'पापमोचनी एकादशी', '2026-03-25', 'ekadashi', true),
  ('होली', 'रंगों का त्योहार - फाल्गुन पूर्णिमा', '2026-03-28', 'utsav', true),
  ('नवरात्रि प्रारंभ', 'चैत्र नवरात्रि का शुभारंभ', '2026-04-08', 'utsav', true),
  ('राम नवमी', 'भगवान श्री राम का जन्मोत्सव', '2026-04-16', 'utsav', true),
  ('हनुमान जयंती', 'श्री हनुमान जी का जन्मोत्सव', '2026-04-22', 'utsav', true),
  ('पूर्णिमा', 'चैत्र पूर्णिमा', '2026-04-26', 'purnima', true),
  ('एकादशी व्रत', 'कामदा एकादशी', '2026-04-10', 'ekadashi', true);

-- 11. Seed sample daily challenges
INSERT INTO daily_challenges (title, description, type, target_value, xp_reward, min_level) VALUES
  ('108 जाप करें', 'आज 108 बार नाम जाप पूरा करें', 'naam_jap', 108, 100, 1),
  ('एक श्लोक पढ़ें', 'किसी एक श्लोक को पढ़ें और मनन करें', 'reading', 1, 50, 1),
  ('सुबह का अनुष्ठान', 'अपने सुबह के अनुष्ठान को पूरा करें', 'ritual', 1, 75, 1),
  ('3 माला पूरी करें', 'आज 3 माला (324 जाप) पूरी करें', 'naam_jap', 324, 200, 6),
  ('5 श्लोक पढ़ें', 'आज 5 अलग-अलग श्लोक पढ़ें', 'reading', 5, 150, 6),
  ('11 माला पूरी करें', 'आज 11 माला (1188 जाप) पूरी करें', 'naam_jap', 1188, 500, 16);

-- 12. Seed sample gyaan content
INSERT INTO daily_gyaan (title, content, difficulty, category) VALUES
  ('भक्ति का अर्थ', 'भक्ति का अर्थ है प्रेमपूर्वक ईश्वर का स्मरण करना। यह केवल मंदिर जाना या पूजा करना नहीं है, बल्कि हर क्षण में ईश्वर को अनुभव करना है।', 1, 'bhakti'),
  ('नाम जाप का महत्व', 'हरि नाम जाप से मन शुद्ध होता है और आत्मा को शांति मिलती है। कलियुग में नाम जाप ही सबसे सरल और प्रभावी साधना है।', 1, 'naam_jap'),
  ('कर्म योग', 'कर्म योग का सार है - बिना फल की इच्छा के अपने कर्तव्य का पालन करना। श्रीकृष्ण ने गीता में कहा - कर्म करो, फल की चिंता मत करो।', 2, 'gita'),
  ('ध्यान की विधि', 'ध्यान में सबसे पहले एक शांत स्थान पर बैठें। आंखें बंद करें और श्वास पर ध्यान दें। मन को किसी एक बिंदु पर केंद्रित करें।', 2, 'meditation'),
  ('माया का स्वरूप', 'माया वह शक्ति है जो हमें सत्य से दूर रखती है। संतों ने कहा है कि माया को जीतने का एकमात्र उपाय है - निरंतर भगवान का स्मरण।', 3, 'vedanta');
