#!/bin/bash
# VrindaVaani - Start Full Application with Supabase

echo "🕉️  Starting VrindaVaani (Supabase Mode)..."
echo ""

# Start backend
echo "🔧 Starting backend..."
cd /Users/mr.bajrangi/Code/Company/Projects/VrindaVaani/backend

if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate
pip install -q -r requirements.txt
pip install -q python-dotenv supabase

python3 supabase_client.py
if [ $? -ne 0 ]; then
    echo "❌ Supabase connection failed. Check backend/.env file."
    exit 1
fi

echo "✅ Backend ready!"
python3 server_supabase.py &
BACKEND_PID=$!

# Wait for backend to start
sleep 3

# Start frontend
echo ""
echo "🎨 Starting frontend..."
cd ../frontend

if [ ! -d "node_modules" ]; then
    echo "📦 Installing npm packages..."
    npm install
fi

echo "✅ Frontend ready!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 VrindaVaani is running!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📱 Frontend: http://localhost:3000"
echo "🔌 Backend API: http://localhost:8000"
echo "📚 API Docs: http://localhost:8000/docs"
echo ""
echo "🗄️  Database: 645 articles in Supabase"
echo ""
echo "Press Ctrl+C to stop all services"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

npm start

# Cleanup on exit
trap "kill $BACKEND_PID 2>/dev/null" EXIT
