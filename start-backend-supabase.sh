#!/bin/bash
# VrindaVaani - Start Backend with Supabase

echo "🔷 Starting VrindaVaani Backend (Supabase Mode)..."

cd /Users/mr.bajrangi/Code/Company/Projects/VrindaVaani/backend

# Check if venv exists, create if not
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install -q -r requirements.txt
pip install -q python-dotenv supabase

# Test connection
echo "🔗 Testing Supabase connection..."
python3 supabase_client.py

if [ $? -eq 0 ]; then
    echo "✅ Supabase connected successfully!"
    echo "🚀 Starting backend server on http://localhost:8000..."
    python3 server_supabase.py
else
    echo "❌ Supabase connection failed. Check your .env file."
    exit 1
fi
