#!/bin/bash
# Sant-Vaani Full Setup for macOS
# This script sets up and runs the complete application with Firebase

echo "╔══════════════════════════════════════════╗"
echo "║   Sant-Vaani Full Setup (with Backend)  ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed${NC}"
    echo "Please install Node.js 18+ from https://nodejs.org"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed${NC}"
    echo "Please install Python 3.8+ from https://python.org"
    exit 1
fi

echo -e "${GREEN}✅ Node.js: $(node --version)${NC}"
echo -e "${GREEN}✅ Python: $(python3 --version)${NC}"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Setup Frontend
echo "📦 Setting up Frontend..."
cd "$SCRIPT_DIR/frontend" || exit 1

if [ ! -d "node_modules" ]; then
    if command -v yarn &> /dev/null; then
        yarn install
    else
        npm install
    fi
fi
echo -e "${GREEN}✅ Frontend ready${NC}"
echo ""

# Setup Backend
echo "📦 Setting up Backend..."
cd "$SCRIPT_DIR/backend" || exit 1

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install requirements
pip install -q -r requirements.txt
echo -e "${GREEN}✅ Backend ready${NC}"
echo ""

# Check for .env file
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${YELLOW}⚠️  Created .env file - please edit with your Firebase credentials${NC}"
    fi
fi

# Detect local IP
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

# Check if servers are already running
BACKEND_RUNNING=$(lsof -ti:8000 2>/dev/null)
FRONTEND_RUNNING=$(lsof -ti:3000 2>/dev/null)

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║            Server Status                 ║"
echo "╚══════════════════════════════════════════╝"
echo ""

if [ -n "$BACKEND_RUNNING" ]; then
    echo -e "${GREEN}✅ Backend is already running on port 8000${NC}"
else
    echo -e "${YELLOW}⚠️  Backend is not running${NC}"
fi

if [ -n "$FRONTEND_RUNNING" ]; then
    echo -e "${GREEN}✅ Frontend is already running on port 3000${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend is not running${NC}"
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║          Access Your Application         ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}📱 Frontend (React App):${NC}"
echo "   • Local:         http://localhost:3000"
if [ -n "$LOCAL_IP" ]; then
    echo "   • Network:       http://$LOCAL_IP:3000"
fi
echo ""
echo -e "${BLUE}🔥 Backend (FastAPI):${NC}"
echo "   • API:           http://localhost:8000"
echo "   • Docs:          http://localhost:8000/docs"
echo "   • Redoc:         http://localhost:8000/redoc"
if [ -n "$LOCAL_IP" ]; then
    echo "   • Network API:   http://$LOCAL_IP:8000"
fi
echo ""

if [ -z "$BACKEND_RUNNING" ] || [ -z "$FRONTEND_RUNNING" ]; then
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║         Start Services Manually          ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""
    
    if [ -z "$BACKEND_RUNNING" ]; then
        echo -e "${YELLOW}Start Backend (Terminal 1):${NC}"
        echo "   cd $SCRIPT_DIR/backend"
        echo "   source venv/bin/activate"
        echo "   python -m uvicorn server:app --reload --host 0.0.0.0"
        echo ""
    fi
    
    if [ -z "$FRONTEND_RUNNING" ]; then
        echo -e "${YELLOW}Start Frontend (Terminal 2):${NC}"
        echo "   cd $SCRIPT_DIR/frontend"
        echo "   npm start"
        echo "   # OR"
        echo "   yarn start"
        echo ""
    fi
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║              Quick Tips                  ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "• View API documentation: http://localhost:8000/docs"
echo "• Frontend runs on:       http://localhost:3000"
if [ -n "$LOCAL_IP" ]; then
    echo "• Access from phone:      http://$LOCAL_IP:3000"
fi
echo "• See QUICK_START.md for detailed setup"
echo ""
