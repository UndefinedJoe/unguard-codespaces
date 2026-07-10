# Unguard DevContainer Quick Start

## ⚡ 30-Second Setup

### If you have VS Code with Dev Containers extension:

1. **Open repo in VS Code**
2. **Press `Cmd+Shift+P`** (Mac) or **`Ctrl+Shift+P`** (Windows/Linux)
3. **Type "Reopen in Container"** and press Enter
4. **Wait for setup** (~10-15 minutes on first run)
5. **Done!** You now have a fully configured environment

## 🎯 Running Unguard (Choose One)

### Option A: Full Kubernetes Setup (Recommended for Development)

**In the devcontainer terminal:**

```bash
# Create a Kubernetes cluster
kind create cluster --name unguard --config ./k8s-manifests/localdev/kind/cluster-config.yaml

# Set up ingress
kubectl apply -k ./k8s-manifests/localdev/kind/

# (Optional) Deploy Dynatrace monitoring (installs the Operator via Helm, then DynaKube)
./dynatrace/setup-dynatrace.sh
```

**If running locally (not in a Codespace):**
```bash
# Add to /etc/hosts (one-time)
echo "127.0.0.1 unguard.kube" >> /etc/hosts

# Deploy all services with Skaffold (watch mode)
skaffold dev
```
Then visit: **http://unguard.kube**

**If running in a GitHub Codespace** (exposes the app via the Codespace's forwarded-port URL instead of `unguard.kube` — no `/etc/hosts` edit needed):
```bash
# Generate an ingress host override for this Codespace
./chart/generate-codespaces-values.sh

# Deploy all services with Skaffold, using the codespaces profile
skaffold dev -p codespaces
```
Then visit the URL printed by `generate-codespaces-values.sh` (`https://$CODESPACE_NAME-80.app.github.dev`) — make sure port 80 is set to **Public** visibility in the Codespace's **Ports** tab if you're testing from outside the Codespace.

> The Dynatrace step requires `DT_URL`, `DT_TOKEN`, and `DT_OPERATOR_TOKEN` to be set — these come from the devcontainer secrets (see `.devcontainer/devcontainer.json`) and are populated automatically when the container starts.

### Option B: Docker Compose (Lightweight, Good for Demos)

**In the devcontainer terminal:**

```bash
# Start everything
docker-compose -f docker-compose.demo.yml --profile full up -d

# Or minimal setup without RAG service
docker-compose -f docker-compose.demo.yml up -d

# Wait for services to be ready (~2-3 minutes)
# Then visit: http://localhost:3000
```

Then visit: **http://localhost:3000**

## 📊 Service Endpoints

### With Kubernetes (http://unguard.kube)
- **Frontend**: http://unguard.kube
- **Jaeger Tracing**: http://unguard.kube/jaeger

### With Docker Compose
- **Frontend**: http://localhost:3000
- **User Auth Service**: http://localhost:3001
- **Microblog Service**: http://localhost:8081
- **Ad Service**: http://localhost:5000
- **Proxy Service**: http://localhost:8082
- **Profile Service**: http://localhost:8083
- **Membership Service**: http://localhost:5001
- **Like Service**: http://localhost:8084
- **Status Service**: http://localhost:8085
- **Payment Service**: http://localhost:8086
- **RAG Service**: http://localhost:8087
- **Jaeger Tracing**: http://localhost:16686

## 🧪 Test the Vulnerabilities

### Example 1: SQL Injection (Profile Service)

```bash
# Create a user first in the frontend, then try SQL injection in bio
curl -X POST http://localhost:8083/profile \
  -H "Content-Type: application/json" \
  -d '{"userId":"1", "bio":"test\"; DROP TABLE users; --"}'
```

### Example 2: SSRF (Proxy Service)

```bash
curl -X POST http://localhost:8082/proxy \
  -H "Content-Type: application/json" \
  -d '{"url":"http://localhost:6379/"}'
```

### Example 3: Run Exploit Toolkit

```bash
cd exploit-toolkit
docker build -t unguard-exploits .
docker run -it --network host unguard-exploits
```

## 🛑 Stopping Services

### With Skaffold:
Press `Ctrl+C` - This will keep the cluster but stop Skaffold

### With Docker Compose:
```bash
docker-compose -f docker-compose.demo.yml down

# To also remove volumes
docker-compose -f docker-compose.demo.yml down -v
```

### Delete Kubernetes Cluster:
```bash
kind delete cluster --name unguard
```

## 🆘 Troubleshooting

### Services won't start
```bash
# Check logs
docker logs <container-name>
# or for Kubernetes
kubectl logs -n unguard <pod-name>
```

### Port already in use
```bash
# Find what's using the port (e.g., 3000)
lsof -i :3000
# Kill it
kill -9 <pid>
```

### Out of memory
Increase Docker's memory:
- **Mac**: Docker Menu → Preferences → Resources → Memory (set to 8GB+)
- **Windows**: Settings → Resources → Memory (set to 8GB+)

### Kubernetes connection errors
```bash
# Check cluster
kubectl cluster-info
# Recreate if needed
kind delete cluster --name unguard
kind create cluster --name unguard --config ./k8s-manifests/localdev/kind/cluster-config.yaml
```

## 📖 Full Documentation

For detailed information, see:
- [DevContainer README](.devcontainer/README.md)
- [Development Guide](docs/DEV-GUIDE.md)
- [Project README](README.md)

## 💡 Tips

- **Auto-reload on changes**: Use `skaffold dev` for automatic rebuilds
- **Check service health**: `kubectl get pods -n unguard` or `docker-compose ps`
- **View logs in real-time**: `skaffold dev --verbosity=debug`
- **Database access**: Connect to MariaDB at `localhost:3306` with user `unguard` / password `unguard123`

## ⚠️ Important

⚠️ **Unguard is intentionally insecure**
- Only run in sandboxed/isolated environments
- Do not expose to the public internet
- This is for education and authorized security testing only

Happy hacking! 🔓
