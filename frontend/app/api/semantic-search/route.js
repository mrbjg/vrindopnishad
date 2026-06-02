import { NextResponse } from 'next/server';
import handler from '../../../api/semantic-search';

export async function GET(request) {
  const { searchParams } = new URL(request.url);
  const q = searchParams.get('q') || '';

  // Create mock req and res objects compatible with the handler
  const req = {
    method: 'GET',
    query: { q },
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
    console.error('Next.js App Router API route semantic-search wrapper error:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
