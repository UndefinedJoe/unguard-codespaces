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
# Use direct download to avoid package conflicts
NODE_VERSION="20.11.0"
curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" | tar -xJ -C /usr/local --strip-components=1

# Install Python (for payment-service and rag-service)
apt-get install -y python3 python3-pip python3-venv
pip3 install --upgrade pip setuptools wheel

# Install Java (for multiple services)
apt-get install -y openjdk-17-jdk maven

# Install .NET SDK (for ad-service and membership-service)
# Use Microsoft's official installer since apt repos may not have it
curl -fsSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 7.0 --install-dir /usr/local/dotnet
ln -sf /usr/local/dotnet/dotnet /usr/local/bin/dotnet
rm dotnet-install.sh

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
echo "🚀 Setting up Kubernetes cluster..."

# Create Kind cluster
if kind get clusters | grep -q "^unguard$"; then
  echo "   ℹ️  Cluster 'unguard' already exists, skipping creation"
else
  kind create cluster --name unguard --config ./k8s-manifests/localdev/kind/cluster-config.yaml
  echo "   ✅ Kind cluster 'unguard' created"
fi

# Set up ingress
echo "📋 Configuring ingress..."
kubectl apply -k ./k8s-manifests/localdev/kind/ 2>/dev/null || echo "   ⚠️  Ingress setup may need manual verification"

# Add unguard.kube to /etc/hosts
echo "🌐 Configuring /etc/hosts..."
if ! grep -q "unguard.kube" /etc/hosts; then
  echo "127.0.0.1 unguard.kube" >> /etc/hosts
  echo "   ✅ Added unguard.kube to /etc/hosts"
else
  echo "   ℹ️  unguard.kube already in /etc/hosts"
fi

echo ""
echo "✨ Unguard DevContainer setup complete!"
echo ""
echo "🚀 Next steps:"
echo ""
echo "  1️⃣  Set up Dynatrace (requires DT_URL, DT_TOKEN, DT_OPERATOR_TOKEN):"
echo "     bash ./dynatrace/setup-dynatrace.sh"
echo ""
echo "  2️⃣  Deploy Unguard with Skaffold:"
echo "     skaffold dev"
echo ""
echo "  📊 Access the application:"
echo "     Frontend: http://unguard.kube"
echo "     Jaeger:   http://unguard.kube/jaeger"
echo ""
echo "  💡 Or skip Kubernetes and use Docker Compose (lighter):"
echo "     docker-compose -f docker-compose.demo.yml --profile full up -d"
echo ""
