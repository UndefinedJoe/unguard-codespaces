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

# Auto-setup Dynatrace if credentials are provided and cluster is ready
echo "🔍 Checking Dynatrace setup status..."

# Check if Kind cluster exists
if ! kind get clusters | grep -q "^unguard$"; then
  echo "   ⚠️  Kind cluster 'unguard' not found. Skipping Dynatrace setup."
  echo "      Run: kind create cluster --name unguard --config ./k8s-manifests/localdev/kind/cluster-config.yaml"
elif [[ -z "$DT_URL" || -z "$DT_TOKEN" || -z "$DT_OPERATOR_TOKEN" ]]; then
  echo "   ℹ️  Dynatrace credentials not set. Skipping auto-setup."
  echo "      To enable, set: DT_URL, DT_TOKEN, DT_OPERATOR_TOKEN"
else
  # Check if Dynatrace Operator is already installed
  if kubectl get namespace dynatrace &> /dev/null && kubectl get deployment -n dynatrace dynatrace-operator &> /dev/null; then
    echo "   ✅ Dynatrace Operator already installed"
  else
    echo "   🚀 Setting up Dynatrace Operator..."
    if bash ./dynatrace/setup-dynatrace.sh; then
      echo "   ✅ Dynatrace setup complete!"
    else
      echo "   ❌ Dynatrace setup failed. Check your credentials and try: bash ./dynatrace/setup-dynatrace.sh"
    fi
  fi
fi

echo ""
