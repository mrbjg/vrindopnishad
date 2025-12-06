#!/bin/bash

# Sant-Vaani Setup Script
# This script sets up the complete development environment

set -e

echo "╔══════════════════════════════════════════╗"
echo "║         Sant-Vaani (Vrindopnishad) Setup            ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+"
    exit 1
fi

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python is not installed. Please install Python 3.8+"
    exit 1
fi

echo "✅ Node.js version: $(node --version)"
echo "✅ Python version: $(python3 --version)"
echo ""

# Frontend Setup
echo "📦 Setting up Frontend..."
cd frontend
if [ ! -d "node_modules" ]; then
    echo "  Installing dependencies..."
    if command -v yarn &> /dev/null; then
        yarn install
    else
        npm install
    fi
    echo "  ✅ Frontend dependencies installed"
else
    echo "  ✅ Frontend dependencies already installed"
fi
cd ..
echo ""

# Backend Setup
echo "📦 Setting up Backend..."
cd backend

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "  Creating Python virtual environment..."
    python3 -m venv venv
    echo "  ✅ Virtual environment created"
fi

# Activate virtual environment
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

# Install Python dependencies
echo "  Installing Python dependencies..."
pip install -q -r requirements.txt
echo "  ✅ Python dependencies installed"

# Check for .env file
if [ ! -f ".env" ]; then
    echo "  Creating .env file from template..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "  ⚠️  Created .env file - please edit with your Firebase credentials"
    fi
else
    echo "  ✅ .env file already exists"
fi

cd ..
echo ""

# Setup Summary
echo "╔══════════════════════════════════════════╗"
echo "║                 Setup Complete! 🎉                 ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo ""
echo "1️⃣  Configure Firebase:"
echo "   - Edit backend/.env with your Firebase credentials"
echo "   - Place firebase-credentials.json in backend/"
echo ""
echo "2️⃣  Start Backend:"
echo "   cd backend && source venv/bin/activate"
echo "   python -m uvicorn server:app --reload"
echo ""
echo "3️⃣  Start Frontend (new terminal):"
echo "   cd frontend && yarn start"
echo ""
echo "4️⃣  Access Application:"
echo "   Frontend: http://localhost:3000"
echo "   API Docs: http://localhost:8000/docs"
echo ""
echo "📖 For detailed setup: cat QUICK_START.md"
echo ""
