#!/bin/bash
set -e

echo "🔧 Setting up Unguard DevContainer..."

# Update system packages
apt-get update
apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    vim \
    nano \
    jq \
    build-essential \
    pkg-config \
    openssl \
    libssl-dev \
    ca-certificates

# Install Node.js (for frontend and user-simulator)
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs npm

# Install Python (for payment-service and rag-service)
apt-get install -y python3 python3-pip python3-venv
pip3 install --upgrade pip setuptools wheel

# Install Java (for multiple services)
apt-get install -y openjdk-17-jdk maven

# Install .NET SDK (for ad-service and membership-service)
apt-get install -y dotnet-sdk-7.0

# Install Go (for status-service)
apt-get install -y golang-go

# Install PHP (for like-service)
apt-get install -y php php-cli php-fpm php-common php-mbstring php-zip php-mysql

# Install Skaffold
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
chmod +x skaffold
mv skaffold /usr/local/bin/

# Install Kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
mv kustomize /usr/local/bin/

# Install Kind (alternative to Minikube)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

# Verify installations
echo ""
echo "✅ Verifying installations..."
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Python: $(python3 --version)"
echo "Java: $(java -version 2>&1 | head -1)"
echo "dotnet: $(dotnet --version)"
echo "Go: $(go version | awk '{print $3}')"
echo "PHP: $(php --version | head -1)"
echo "Docker: $(docker --version)"
echo "kubectl: $(kubectl version --client --short 2>/dev/null || echo 'Not yet available')"
echo "Helm: $(helm version --short 2>/dev/null || echo 'Not yet available')"
echo "Skaffold: $(skaffold version)"
echo "Kustomize: $(kustomize version --short)"
echo "Kind: $(kind --version)"

echo ""
echo "✨ Unguard DevContainer setup complete!"
echo ""
echo "🚀 Next steps:"
echo "  1. For Kubernetes deployment with Skaffold:"
echo "     kind create cluster --name unguard"
echo "     kubectl apply -k ./k8s-manifests/localdev/kind/"
echo "     skaffold dev"
echo ""
echo "  2. Or for Docker Compose (lighter):"
echo "     docker-compose -f docker-compose.yml up -d"
echo ""
