#!/bin/bash
# Sant-Vaani Quick Start for macOS
# This script starts the application in demo mode (no Firebase needed)

echo "╔══════════════════════════════════════════╗"
echo "║   Sant-Vaani Quick Start (Demo Mode)    ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "Starting frontend in demo mode..."
echo ""

# Navigate to frontend directory
cd "$(dirname "$0")/frontend" || exit 1

# Check if node_modules exists, if not install dependencies
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies (first time only)..."
    if command -v yarn &> /dev/null; then
        echo "Using Yarn..."
        yarn install
    else
        echo "Using NPM..."
        npm install
    fi
    echo ""
fi

# Start the application in demo mode
echo "🚀 Starting application..."
echo ""
export REACT_APP_BACKEND_URL="http://localhost:8000"
export REACT_APP_DEMO_MODE="true"

if command -v yarn &> /dev/null; then
    yarn start
else
    npm start
fi