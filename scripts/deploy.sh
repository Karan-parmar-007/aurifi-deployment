#!/bin/bash

set -e

echo "🚀 Starting Aurifi deployment..."

# Load environment variables
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "📝 Please copy .env.example to .env and configure it"
    exit 1
fi

source .env

# Validate required variables
required_vars=("MONGO_URI" "SECRET_KEY" "FRONTEND_REPO" "BACKEND_REPO")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: $var is not set in .env"
        exit 1
    fi
done

echo "📦 Cloning/updating repositories..."

# Clone or update frontend
if [ ! -d "frontend" ]; then
    echo "Cloning frontend repository..."
    git clone $FRONTEND_REPO frontend
else
    echo "Updating frontend repository..."
    cd frontend && git pull origin main && cd ..
fi

# Clone or update backend
if [ ! -d "backend" ]; then
    echo "Cloning backend repository..."
    git clone $BACKEND_REPO backend
else
    echo "Updating backend repository..."
    cd backend && git pull origin main && cd ..
fi

echo "🔨 Building and starting services..."

# Stop existing services
docker compose down --remove-orphans

# Build and start services
docker compose up -d --build

echo "🧹 Cleaning up..."
docker image prune -f

echo "🔍 Running health checks..."
sleep 15

if curl -f http://localhost > /dev/null 2>&1; then
    echo "✅ Frontend is healthy"
else
    echo "❌ Frontend health check failed"
fi

if curl -f http://localhost/api/ > /dev/null 2>&1; then
    echo "✅ Backend is healthy"
else
    echo "❌ Backend health check failed"
fi

echo "📊 Service status:"
docker compose ps

echo "✅ Deployment completed!"
echo "🌐 Access your application at: http://165.22.214.208"