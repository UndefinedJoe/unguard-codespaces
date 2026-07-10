# Unguard DevContainer Setup

This directory contains the DevContainer configuration for running **Unguard** - a vulnerable microservices demo application designed for security testing, demos, and PoCs.

## 📋 Prerequisites

- **Docker Desktop** (Mac/Windows) or **Docker Engine** (Linux)
- **Visual Studio Code** with the "Dev Containers" extension
- At least **4GB RAM** allocated to Docker (8GB+ recommended for full deployment)
- At least **20GB free disk space**

## 🚀 Getting Started

### Option 1: Using VS Code Dev Containers (Recommended)

1. **Install the Dev Containers extension** in VS Code:
   - Open VS Code
   - Go to Extensions (Ctrl+Shift+X / Cmd+Shift+X)
   - Search for "Dev Containers" and install the Microsoft extension

2. **Open the project in a container:**
   - Open the Unguard repository in VS Code
   - Click the green icon in the bottom-left corner
   - Select "Reopen in Container"
   - Wait for the container to build and initialize (~10-15 minutes on first run)

3. **Verify the setup:**
   ```bash
   docker ps
   skaffold version
   kubectl version --client
   ```

### Option 2: Manual Container Launch

```bash
# Build the devcontainer image
docker build -f .devcontainer/Dockerfile -t unguard-devcontainer .

# Run with Docker socket mounted
docker run -it --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd):/workspace \
  unguard-devcontainer
```

## 🎯 Running Unguard

### Path 1: Kubernetes + Skaffold (Full Stack - Recommended for Development)

This is the primary way to run Unguard with all 16+ services in a full microservices environment.

**Step 1: Create a Kind cluster**
```bash
kind create cluster --name unguard --config ./k8s-manifests/localdev/kind/cluster-config.yaml
```

**Step 2: Set up ingress**
```bash
kubectl apply -k ./k8s-manifests/localdev/kind/
```

**Step 3: Expose the ingress**

If running locally (not in a Codespace), map `unguard.kube` to localhost (one-time):
```bash
echo "127.0.0.1 unguard.kube" >> /etc/hosts
```

If running in a GitHub Codespace, generate an ingress host override pointing at this Codespace's forwarded-port URL instead (no `/etc/hosts` edit — see Step 5 for the matching Skaffold profile):
```bash
./chart/generate-codespaces-values.sh
```

**Step 4: (Optional) Deploy Dynatrace monitoring**
```bash
# Requires DT_URL, DT_TOKEN, and DT_OPERATOR_TOKEN to be set (populated automatically
# from the devcontainer secrets — see .devcontainer/devcontainer.json)
# Installs the Dynatrace Operator via Helm, then creates the secret and applies DynaKube.
./dynatrace/setup-dynatrace.sh
```

**Step 5: Start with Skaffold**

If running locally:
```bash
# Watch mode - auto-rebuilds on code changes
skaffold dev

# Or just deploy once
skaffold run
```

If running in a GitHub Codespace, use the `codespaces` profile so the ingress picks up the host generated in Step 3:
```bash
skaffold dev -p codespaces

# Or just deploy once
skaffold run -p codespaces
```

**Step 6: Access the application**
- Local: Frontend at http://unguard.kube
- Codespace: Frontend at the URL printed by `generate-codespaces-values.sh` (`https://$CODESPACE_NAME-80.app.github.dev`) — set port 80 to **Public** visibility in the **Ports** tab if testing from outside the Codespace
- Jaeger Tracing: http://localhost:16686

### Path 2: Docker Compose (Lightweight Demo)

For a simpler setup without Kubernetes knowledge, use Docker Compose.

**Step 1: Set up environment variables** (optional)
```bash
cp .env.example .env
# Edit .env if you want to change defaults
```

**Step 2: Start services**
```bash
# Minimal setup (just core services)
docker-compose -f docker-compose.demo.yml up -d

# Or with RAG service
docker-compose -f docker-compose.demo.yml --profile rag up -d

# Full stack with all services
docker-compose -f docker-compose.demo.yml --profile full up -d
```

**Step 3: Access the application**
- Frontend: http://localhost:3000
- User Auth Service: http://localhost:3001
- Microblog Service: http://localhost:8081
- Jaeger: http://localhost:16686

**Step 4: Stop services**
```bash
docker-compose -f docker-compose.demo.yml down
```

## 📚 Available Commands

### Kubernetes & Skaffold
```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes

# View pods
kubectl get pods -n unguard
kubectl logs -n unguard <pod-name>

# Build services with Skaffold
skaffold build

# Deploy without watch mode
skaffold run

# Delete deployment
skaffold delete

# View available profiles (e.g., tracing)
grep "^  - name:" skaffold.yaml
```

### Docker Compose
```bash
# List running services
docker-compose -f docker-compose.demo.yml ps

# View logs
docker-compose -f docker-compose.demo.yml logs -f <service-name>

# Execute command in a service
docker-compose -f docker-compose.demo.yml exec <service-name> /bin/bash

# Rebuild a specific service
docker-compose -f docker-compose.demo.yml build <service-name>
```

### General
```bash
# Check Docker status
docker ps
docker images

# View container logs
docker logs <container-id>

# Access container shell
docker exec -it <container-id> /bin/bash
```

## 🔐 Security Features to Test

Unguard is intentionally vulnerable. Here are some of the exploitable features:

- **SSRF** - Proxy Service
- **SQL Injection** - Profile, Membership, Like, Status services
- **JWT Key Confusion** - User Auth Service
- **Command Injection** - Multiple services
- **Remote Code Execution** - Via Jackson library in Microblog Service
- **Data Poisoning** - RAG Service

Check the [exploit toolkit](../exploit-toolkit/exploits/README.md) for automated attack scenarios.

## 🛠️ Development Workflow

### Editing Code

With `skaffold dev`, changes to code are automatically detected and services are rebuilt:

1. Edit a service's source code
2. Skaffold detects the change
3. Service is rebuilt and redeployed
4. New version is available immediately

### Running Tests

Each service has its own test suite:

```bash
cd src/<service-name>
# See the service's README for test commands
```

### Building Specific Services

```bash
# Build just one image
skaffold build -b <image-name>

# View build plan
skaffold build --dry-run
```

## 🔧 Troubleshooting

### Issue: Port already in use
```bash
# Find what's using the port
lsof -i :<port-number>

# Kill the process
kill -9 <pid>
```

### Issue: Kubernetes connection errors
```bash
# Check cluster status
kubectl cluster-info

# Recreate cluster if needed
kind delete cluster --name unguard
kind create cluster --name unguard --config ./k8s-manifests/localdev/kind/cluster-config.yaml
```

### Issue: Services not starting
```bash
# Check pod status
kubectl get pods -n unguard -o wide

# View pod logs
kubectl logs -n unguard <pod-name>

# Describe pod for events
kubectl describe pod -n unguard <pod-name>
```

### Issue: Docker daemon not running (Docker-in-Docker)
The Docker daemon should start automatically. If not:
```bash
dockerd &
```

### Issue: Out of memory
Increase Docker's allocated memory:
- **Docker Desktop (Mac)**: Docker → Preferences → Resources → Memory (increase to 8GB+)
- **Docker Desktop (Windows)**: Settings → Resources → Memory (increase to 8GB+)

## 📖 Documentation

- [Development Guide](../docs/DEV-GUIDE.md) - Detailed dev setup
- [Architecture](../docs/images/unguard-architecture.svg) - System design
- [Exploits](../exploit-toolkit/exploits/README.md) - Attack scenarios
- [README](../README.md) - Project overview

## 🐛 Reporting Issues

If you encounter issues with the DevContainer setup:

1. Check the logs: `docker logs <container-id>`
2. Verify prerequisites are installed
3. Try rebuilding the container
4. Check available disk space and memory

## 💡 Tips for Demos/PoCs

### Quick Start for Presentations
```bash
# Use docker-compose for simplicity
docker-compose -f docker-compose.demo.yml --profile full up -d
# Wait for services to be ready (~2-3 minutes)
# Open http://localhost:3000 in browser
```

### Running Exploit Toolkit
```bash
cd exploit-toolkit
docker build -t unguard-exploit-toolkit .
docker run -it --network host unguard-exploit-toolkit
```

### Creating Test Data
The user-simulator creates synthetic traffic and test accounts automatically when running.

### Capturing Network Traffic
```bash
# Proxy service is vulnerable to SSRF
# Use it to test various URL schemes and internal services
curl -X POST http://localhost:8082/proxy \
  -H "Content-Type: application/json" \
  -d '{"url":"http://metadata.internal/..."}'
```

## 📋 Installed Tools

The DevContainer includes:

- **Runtime Environments**: Node.js 20, Python 3, Java 17, .NET 7, Go, PHP
- **Kubernetes**: kubectl, Helm, Kind, Minikube
- **CI/CD**: Skaffold, Kustomize
- **Container**: Docker with BuildKit
- **Development**: Git, Make, build-essential
- **IDEs Extensions**: Kubernetes, Docker, Language support (Java, Go, Python, C#)

## 🔄 Updating the DevContainer

If the DevContainer configuration changes:

1. Rebuild: `Cmd+Shift+P` → "Dev Containers: Rebuild Container"
2. Or from terminal: `docker build -f .devcontainer/Dockerfile .`

## 📝 Environment Variables

Create a `.env` file in the project root for docker-compose:

```bash
# Database
DB_ROOT_PASSWORD=unguard
DB_PASSWORD=unguard123

# JWT
JWT_SECRET=your-secret-key-change-in-production

# Logging
LOG_LEVEL=info
```

## ⚠️ Important Notes

- **Unguard is intentionally insecure** - Only run in sandboxed/isolated environments
- **Not production-ready** - This is for education and testing only
- **Network isolation** - Use Docker networks to isolate from other systems
- **Data persistence** - Use `docker-compose down -v` to clean up all data
