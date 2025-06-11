#!/bin/bash

set -e

echo "🚀 Starting Aurifi deployment..."

# Load environment variables
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    exit 1
fi

source .env

echo "🧹 Cleaning up existing containers and images..."
docker compose down --remove-orphans
docker system prune -f

echo "📦 Updating repositories..."

# Remove existing directories to ensure clean state
sudo rm -rf frontend backend

# Clone repositories
echo "Cloning frontend repository..."
git clone $FRONTEND_REPO frontend

echo "Cloning backend repository..."
git clone $BACKEND_REPO backend

# Create frontend .env file with correct API URL
echo "Setting up frontend environment..."
cat > frontend/.env << EOF
VITE_API_URL=http://165.22.214.208/api/v1
NODE_ENV=production
EOF

echo "🔨 Building and starting services..."
docker compose up -d --build

echo "⏳ Waiting for services to start..."
sleep 30

echo "📊 Service status:"
docker compose ps

echo "🔍 Testing API endpoints..."
echo "Testing user endpoint:"
curl -I http://165.22.214.208/api/v1/user/

echo "Testing auth endpoint:"
curl -I http://165.22.214.208/api/v1/auth/

echo "✅ Deployment completed!"
echo "🌐 Frontend: http://165.22.214.208"
echo "🔗 API Base: http://165.22.214.208/api/v1"