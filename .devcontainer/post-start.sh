#!/bin/bash

echo "🎯 Starting Unguard environment..."

# Check if Docker daemon is running
if ! docker info > /dev/null 2>&1; then
    echo "⚠️  Docker daemon not running. Starting docker..."
    # Docker-in-Docker should handle this automatically
fi

# Create a helpful startup message
cat << 'EOF'

╔════════════════════════════════════════════════════════════════╗
║                  Welcome to Unguard DevContainer               ║
║                                                                ║
║  This container is configured to run the vulnerable           ║
║  microservices demo application Unguard.                      ║
╚════════════════════════════════════════════════════════════════╝

📚 Quick Reference:

  🐳 Kubernetes + Skaffold (Full Stack):
    kind create cluster --name unguard
    kubectl apply -k ./k8s-manifests/localdev/kind/
    skaffold dev

  🐋 Docker Compose (Simple Demo):
    docker-compose -f docker-compose.yml up -d
    # Access at http://localhost:8080

  📖 Documentation:
    - Development Guide: docs/DEV-GUIDE.md
    - Architecture: docs/images/unguard-architecture.svg
    - Exploits: exploit-toolkit/exploits/README.md

  🔨 Useful Commands:
    docker ps          # List running containers
    kubectl get pods   # List Kubernetes pods
    skaffold build     # Build without deploying
    kind get clusters  # List Kind clusters

EOF

# Optional: Auto-create Kind cluster on container start (comment out if not desired)
# if ! kind get clusters | grep -q unguard; then
#     echo "📦 Creating Kind cluster 'unguard'..."
#     kind create cluster --name unguard
#     kubectl apply -k ./k8s-manifests/localdev/kind/
# fi

echo ""
