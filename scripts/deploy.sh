#!/bin/bash

set -e

echo "🚀 Starting Aurifi deployment..."

# Load environment variables
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    exit 1
fi

source .env

echo "🛑 Stopping existing services..."
docker compose down

echo "📥 Pulling latest images..."
docker pull ${DOCKERHUB_USERNAME}/aurifi-frontend:latest
docker pull ${DOCKERHUB_USERNAME}/aurifi-backend:latest

echo "🧹 Cleaning up old images..."
docker image prune -f

echo "🚀 Starting services with new images..."
docker compose up -d

echo "⏳ Waiting for services to start..."
sleep 30

echo "🔍 Health checks..."
if curl -f http://localhost > /dev/null 2>&1; then
    echo "✅ Frontend is healthy"
else
    echo "❌ Frontend health check failed"
    docker compose logs frontend
fi

if curl -f http://localhost/api/v1/auth/ > /dev/null 2>&1; then
    echo "✅ Backend is healthy"
else
    echo "❌ Backend health check failed"
    docker compose logs backend
fi

echo "📊 Service status:"
docker compose ps

echo "✅ Deployment completed!"
echo "🌐 Frontend: http://165.22.214.208"
echo "🔗 API Base: http://165.22.214.208/api/v1"