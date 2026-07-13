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
  const refExplain = dbVerse?.hindi_text || dbVerse?.description || hindi_text || '';
  const refAuthor = dbVerse?.author || author || '';
  const refTitle = dbVerse?.title || title || '';

  const systemPrompt = `You are a humble Brajwasi devotee of Shri Radha-Krishna. You have deep bhakti, respect, and love for the Rasik saints of Vrindavan.
Your task is to explain and translate the given sacred verse/lyrics in the requested language: ${targetLang === 'hi' ? 'Hindi (हिंदी)' : 'English'}.

Follow these guidelines strictly:
1. Adopt the voice and attitude of a sweet, humble devotee (Brajwasi) expressing bhakti, loving reverence, and deep spiritual insight. Use expressions like "जय श्री राधे", "रसिक संतों की कृपा", "ठाकुर जी की लीला" naturally.
2. Structure your explanation beautifully:
   - First, give a summary of the inner devotional mood (भावार्थ/spiritual essence).
   - Second, explain the meaning line-by-line or phrase-by-phrase with deep spiritual depth.
3. COPYRIGHT PROTECTION RULE: You are provided with a reference commentary/explanation. Do NOT copy the reference commentary verbatim. You must paraphrase it completely, rewriting it in your own beautiful, devotee-like words so that there are absolutely no copyright concerns.
4. Do NOT use generic AI introductory phrases (like "Here is the explanation..." or "Sure, I can help with that"). Start directly with a devotional greeting (e.g., "जय श्री राधे।") followed by the explanation.`;

  const userContent = `Verse/Lyrics details:
Title: ${refTitle}
Author: ${refAuthor}
Sacred Text (Verse):
${verseText}

Reference Explanation (for context - do not copy verbatim):
${refExplain}`;

  // 1. Try Groq
  const GROQ_API_KEY = process.env.GROQ_API_KEY;
  if (GROQ_API_KEY) {
    try {
      console.log('[Explain] Attempting Groq...');
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
          temperature: 0.6
        })
      });

      if (response.ok) {
        const data = await response.json();
        const text = data?.choices?.[0]?.message?.content;
        if (text) {
          return { success: true, explanation: text.trim() };
        }
      } else {
        const errText = await response.text();
        console.error(`[Explain] Groq failed: Status ${response.status} - ${errText}`);
      }
    } catch (e) {
      console.error('[Explain] Groq connection error:', e);
    }
  }

  // 2. Try Gemini
  const GEMINI_API_KEY = process.env.GEMINI_API_KEY || process.env.REACT_APP_GEMINI_API_KEY;
  if (GEMINI_API_KEY) {
    try {
      console.log('[Explain] Attempting Gemini fallback...');
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`;
      const response = await fetch(geminiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                { text: `${systemPrompt}\n\n${userContent}` }
              ]
            }
          ],
          generationConfig: {
            temperature: 0.6
          }
        })
      });

      if (response.ok) {
        const data = await response.json();
        const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
        if (text) {
          return { success: true, explanation: text.trim() };
        }
      } else {
        const errText = await response.text();
        console.error(`[Explain] Gemini failed: Status ${response.status} - ${errText}`);
      }
    } catch (e) {
      console.error('[Explain] Gemini connection error:', e);
    }
  }

  // Fallback if both fail
  const fallbackMsg = targetLang === 'hi'
    ? 'हे रसिक! इस समय ठाकुर जी की लीला में कुछ व्यवधान आ गया है। कृपया कुछ समय बाद पुनः प्रयास करें। जय श्री राधे! 🙏 (व्याख्या सेवा अभी उपलब्ध नहीं है)'
    : 'Dear devotee, there is a temporary interruption in retrieving the explanation. Please try again in a moment. Jai Shri Radhe! 🙏 (Explanation service temporarily offline)';

  return {
    success: false,
    message: fallbackMsg,
    explanation: fallbackMsg
  };
}

export async function POST(request) {
  let body = {};
  try {
    body = await request.json();
  } catch (e) {
    console.error('[Explain Route] Failed to parse request JSON:', e.message);
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
    console.error('Next.js App Router API route explain error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function OPTIONS() {
  const headers = new Headers();
  headers.set('Access-Control-Allow-Origin', '*');
  headers.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  return new Response(null, {
    status: 200,
    headers: headers,
  });
}
