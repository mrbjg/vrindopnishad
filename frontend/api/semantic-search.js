/**
 * Vercel Serverless Function — AI Semantic Search
 * Uses HuggingFace Inference API for multilingual semantic similarity
 * Endpoint: /api/semantic-search?q=radha+krishna+bhajan
 */

const HF_MODEL = 'sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2';
const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || 'https://tilimltxgeucefxzerqi.supabase.co';
const SUPABASE_KEY = process.env.REACT_APP_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY;
const HF_TOKEN = process.env.HF_TOKEN;

// In-memory cache (persists across warm starts)
let cachedContent = null;
let cachedEmbeddings = null;
let cacheTimestamp = 0;
const CACHE_TTL = 30 * 60 * 1000; // 30 min

// --- HuggingFace API ---
async function getEmbeddings(texts) {
  const res = await fetch(
    `https://api-inference.huggingface.co/pipeline/feature-extraction/${HF_MODEL}`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${HF_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        inputs: texts,
        options: { wait_for_model: true },
      }),
    }
  );
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`HF API error ${res.status}: ${err}`);
  }
  return res.json();
}

// --- Supabase REST API (no SDK needed in serverless) ---
async function fetchContent() {
  const res = await fetch(
    `${SUPABASE_URL}/rest/v1/content?select=id,title,slug,category,author,hindi_text,description&order=created_at.desc`,
    {
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
      },
    }
  );
  if (!res.ok) throw new Error(`Supabase error: ${res.status}`);
  return res.json();
}

// --- Math ---
function cosineSimilarity(a, b) {
  let dot = 0, normA = 0, normB = 0;
  for (let i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  return dot / (Math.sqrt(normA) * Math.sqrt(normB));
}

// Pool token embeddings to sentence embedding (mean pooling)
function meanPool(embedding) {
  if (!Array.isArray(embedding[0])) return embedding; // already 1D
  const len = embedding.length;
  const dim = embedding[0].length;
  const result = new Array(dim).fill(0);
  for (let i = 0; i < len; i++) {
    for (let j = 0; j < dim; j++) {
      result[j] += embedding[i][j];
    }
  }
  return result.map(v => v / len);
}

// --- Main Handler ---
export default async function handler(req, res) {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  if (req.method === 'OPTIONS') return res.status(200).end();

  const query = req.query.q;
  if (!query || query.trim().length < 2) {
    return res.status(400).json({ error: 'Query too short (min 2 chars)' });
  }

  if (!HF_TOKEN) {
    return res.status(500).json({ error: 'HF_TOKEN not configured' });
  }

  try {
    const now = Date.now();

    // 1. Load content + embeddings (cached for warm starts)
    if (!cachedContent || !cachedEmbeddings || now - cacheTimestamp > CACHE_TTL) {
      console.log('Cache miss — fetching content from Supabase...');
      cachedContent = await fetchContent();

      // Embed all titles (batch in chunks of 64)
      const titles = cachedContent.map(
        (c) => `${c.title || ''} ${c.author || ''} ${c.category || ''}`
      );
      const embeddings = [];
      for (let i = 0; i < titles.length; i += 64) {
        const chunk = titles.slice(i, i + 64);
        const chunkEmb = await getEmbeddings(chunk);
        embeddings.push(...chunkEmb.map(meanPool));
      }

      cachedEmbeddings = embeddings;
      cacheTimestamp = now;
      console.log(`Cached ${cachedContent.length} items with embeddings`);
    }

    // 2. Embed the query
    const queryEmbRaw = await getEmbeddings([query.trim()]);
    const queryEmb = meanPool(queryEmbRaw[0]);

    // 3. Compute similarity scores
    const scored = cachedContent.map((item, i) => ({
      id: item.id,
      title: item.title,
      slug: item.slug,
      category: item.category,
      author: item.author,
      description: item.description?.substring(0, 120),
      score: cosineSimilarity(queryEmb, cachedEmbeddings[i]),
    }));

    // 4. Sort by score, return top 6
    scored.sort((a, b) => b.score - a.score);
    const results = scored.slice(0, 6).filter((r) => r.score > 0.25);

    return res.status(200).json({
      query,
      results,
      model: HF_MODEL,
      cached: now - cacheTimestamp < 1000 ? false : true,
    });
  } catch (error) {
    console.error('Semantic search error:', error);
    return res.status(500).json({ error: error.message });
  }
}
