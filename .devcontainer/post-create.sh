#!/bin/bash
set -e

echo "🔧 Setting up Unguard DevContainer..."
echo "   (Universal image pre-installed: Node.js, Python, Java, .NET, Go, PHP, Docker, kubectl, Helm)"

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
