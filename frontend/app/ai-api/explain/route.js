import { NextResponse } from 'next/server';

export const runtime = 'edge';

const SUPABASE_URL = process.env.REACT_APP_SUPABASE_URL || 'https://tilimltxgeucefxzerqi.supabase.co';
const SUPABASE_KEY = process.env.REACT_APP_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY;

async function handleExplain(body) {
  const { content_id, sanskrit_text, hindi_text, author, title, language } = body || {};
  const targetLang = (language || 'hi').toLowerCase();

  // Load from Supabase to protect copyright reference
  let dbVerse = null;
  if (content_id) {
    try {
      const response = await fetch(
        `${SUPABASE_URL}/rest/v1/content?id=eq.${content_id}&limit=1`,
        {
          headers: {
            'apikey': SUPABASE_KEY,
            'Authorization': `Bearer ${SUPABASE_KEY}`
          }
        }
      );
      if (response.ok) {
        const data = await response.json();
        if (Array.isArray(data) && data.length > 0) {
          dbVerse = data[0];
        }
      }
    } catch (e) {
      console.error('[Explain] Supabase fetch failed:', e.message);
    }
  }

  const verseText = dbVerse?.sanskrit_text || sanskrit_text || '';
  const refMeaning = dbVerse?.hindi_text || dbVerse?.description || hindi_text || '';
  const refAuthor = dbVerse?.author || author || '';
  const refTitle = dbVerse?.title || title || '';

  // Concise prompt - uses reference meaning to understand verse, outputs brief devotional explanation
  const systemPrompt = `You are a humble Brajwasi devotee. Explain the sacred verse briefly and devotionally.
Rules:
- Language: ${targetLang === 'hi' ? 'Hindi (हिंदी)' : 'English'}.
- Start with "जय श्री राधे।"
- One short paragraph for the overall spiritual mood (2-3 sentences).
- Then explain each verse line in 1 line. Total: 80-120 words max.
- Use the reference meaning to understand the verse — paraphrase in your own devotional words, never copy it.
- No generic AI phrases.`;

  const userContent = `Verse by ${refAuthor}: "${refTitle}"
---
${verseText}
---
Reference meaning (understand only, do not copy):
${refMeaning}`;

  // 1. Try Groq
  const GROQ_API_KEY = process.env.GROQ_API_KEY;
  if (GROQ_API_KEY) {
    try {
      const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${GROQ_API_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          model: 'llama-3.1-8b-instant',
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: userContent }
          ],
          temperature: 0.65,
          max_tokens: 400
        })
      });

      if (response.ok) {
        const data = await response.json();
        const text = data?.choices?.[0]?.message?.content;
        if (text) return { success: true, explanation: text.trim() };
      } else {
        const errText = await response.text();
        console.error(`[Explain] Groq failed: ${response.status} - ${errText}`);
      }
    } catch (e) {
      console.error('[Explain] Groq error:', e);
    }
  }

  // 2. Try Gemini fallback
  const GEMINI_API_KEY = process.env.GEMINI_API_KEY || process.env.REACT_APP_GEMINI_API_KEY;
  if (GEMINI_API_KEY) {
    try {
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`;
      const response = await fetch(geminiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: `${systemPrompt}\n\n${userContent}` }] }],
          generationConfig: { temperature: 0.65, maxOutputTokens: 400 }
        })
      });

      if (response.ok) {
        const data = await response.json();
        const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
        if (text) return { success: true, explanation: text.trim() };
      } else {
        const errText = await response.text();
        console.error(`[Explain] Gemini failed: ${response.status} - ${errText}`);
      }
    } catch (e) {
      console.error('[Explain] Gemini error:', e);
    }
  }

  const fallbackMsg = targetLang === 'hi'
    ? 'जय श्री राधे 🙏 इस समय व्याख्या सेवा उपलब्ध नहीं है। कृपया कुछ समय बाद पुनः प्रयास करें।'
    : 'Jai Shri Radhe 🙏 Explanation service is temporarily unavailable. Please try again shortly.';

  return { success: false, message: fallbackMsg, explanation: fallbackMsg };
}

export async function POST(request) {
  let body = {};
  try {
    body = await request.json();
  } catch (e) {
    console.error('[Explain Route] Failed to parse JSON:', e.message);
  }

  try {
    const result = await handleExplain(body);
    return NextResponse.json(result, {
      status: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      }
    });
  } catch (error) {
    console.error('[Explain Route] Error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function OPTIONS() {
  const headers = new Headers();
  headers.set('Access-Control-Allow-Origin', '*');
  headers.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  return new Response(null, { status: 200, headers });
}
