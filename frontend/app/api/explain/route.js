import { NextResponse } from 'next/server';
import handler from '../../../api/explain';

export async function POST(request) {
  let body = {};
  try {
    body = await request.json();
  } catch (e) {
    console.error('[Explain Route] Failed to parse request JSON:', e.message);
  }

  const req = {
    method: 'POST',
    body: body,
    query: {},
  };

  let statusCode = 200;
  let responseData = null;
  const headers = new Headers();

  const res = {
    setHeader(key, value) {
      headers.set(key, value);
    },
    status(code) {
      statusCode = code;
      return this;
    },
    json(data) {
      responseData = data;
      return this;
    },
    end() {
      return this;
    },
  };

  try {
    await handler(req, res);
    return NextResponse.json(responseData || {}, {
      status: statusCode,
      headers: headers,
    });
  } catch (error) {
    console.error('Next.js App Router API route explain wrapper error:', error);
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
