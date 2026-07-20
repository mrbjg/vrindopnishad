import fs from 'fs';
import path from 'path';
import { hinglishMatch, normalizeForFuzzy } from '../src/utils/hinglishSearch';
import { transliterate } from '../src/utils/transliterate';

let cachedContent = null;

function fetchContent() {
  if (cachedContent) return cachedContent;
  
  let localFilePath = path.join(process.cwd(), 'data/vrindavaani_content.json');
  if (!fs.existsSync(localFilePath)) {
    localFilePath = path.join(process.cwd(), 'frontend/data/vrindavaani_content.json');
  }
  if (!fs.existsSync(localFilePath)) {
    localFilePath = path.join(process.cwd(), 'admin/data/vrindavaani_content.json');
  }

  if (fs.existsSync(localFilePath)) {
    const fileContent = fs.readFileSync(localFilePath, 'utf8');
    cachedContent = JSON.parse(fileContent);
    return cachedContent;
  }
  throw new Error('Content file not found');
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  if (req.method === 'OPTIONS') return res.status(200).end();

  const query = req.query.q;
  if (!query || query.trim().length < 2) {
    return res.status(400).json({ error: 'Query too short (min 2 chars)' });
  }

  try {
    const content = fetchContent();
    const cleanQuery = query.trim().toLowerCase();
    
    // Split query into individual words for term matching
    const queryWords = cleanQuery.split(/\s+/).filter(w => w.length >= 2);
    const queryHinglish = transliterate(cleanQuery);
    const queryHinglishWords = queryHinglish.split(/\s+/).filter(w => w.length >= 2);

    const scored = content.map((item) => {
      let score = 0;
      
      // Compute search indices if not present
      if (!item._textDevanagari) {
        const sansFirstLine = item.sanskrit_text ? item.sanskrit_text.split(/[\n।॥]/).map(l => l.trim()).filter(Boolean)[0] || '' : '';
        const hindiFirstLine = item.hindi_text ? item.hindi_text.split(/[\n।॥]/).map(l => l.trim()).filter(Boolean)[0] || '' : '';

        item._textDevanagari = [
          item.title,
          item.name,
          item.hindi_text,
          item.sanskrit_text,
          item.author,
          item.description,
          item.category,
          sansFirstLine,
          hindiFirstLine
        ].filter(Boolean).join(' ').toLowerCase();

        item._textHinglish = [
          item.hinglishName,
          transliterate(item.title || ''),
          transliterate(item.name || ''),
          transliterate(item.author || ''),
          transliterate(item.description || ''),
          transliterate(sansFirstLine),
          transliterate(hindiFirstLine),
          item.english_translation,
          item.english_text,
          item.slug,
          ...(item.tags || [])
        ].filter(Boolean).join(' ').toLowerCase();

        item._normalizedHinglish = normalizeForFuzzy(item._textHinglish);
      }

      // 1. Direct match check (exact phrase match)
      if (item._textDevanagari.includes(cleanQuery)) {
        score += 0.8;
        // Extra boost if it matches in the title
        if ((item.title || '').toLowerCase().includes(cleanQuery)) {
          score += 0.2;
        }
      } else if (item._textHinglish.includes(queryHinglish)) {
        score += 0.7;
        if (transliterate(item.title || '').toLowerCase().includes(queryHinglish)) {
          score += 0.25;
        }
      }

      // 2. Individual word matches (term frequency / overlap)
      let wordMatches = 0;
      const totalWords = queryWords.length + queryHinglishWords.length;
      
      if (totalWords > 0) {
        queryWords.forEach(word => {
          if (item._textDevanagari.includes(word)) wordMatches++;
        });
        queryHinglishWords.forEach(word => {
          if (item._textHinglish.includes(word)) wordMatches++;
        });
        score += (wordMatches / totalWords) * 0.4;
      }

      // 3. Category/Author matching boost
      if (item.author && cleanQuery.includes(item.author.toLowerCase())) {
        score += 0.15;
      }
      if (item.category && cleanQuery.includes(item.category.toLowerCase())) {
        score += 0.05;
      }

      return {
        id: item.id,
        title: item.title,
        slug: item.slug,
        category: item.category,
        author: item.author,
        description: item.description?.substring(0, 120),
        score: Math.min(score, 1.0)
      };
    });

    // Sort by score descending and filter out poor results
    const results = scored
      .filter(item => item.score > 0.25)
      .sort((a, b) => b.score - a.score)
      .slice(0, 6);

    return res.status(200).json({
      query,
      results,
      model: 'local-hybrid-search-v1',
      cached: true
    });
  } catch (error) {
    console.error('Semantic search api error:', error);
    return res.status(500).json({ error: error.message });
  }
}
