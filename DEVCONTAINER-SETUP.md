# DevContainer Setup Summary

This document describes the DevContainer configuration that has been added to the Unguard project to make it easy to run, demo, and test in a standardized environment.

## 📦 What Was Created

### 1. DevContainer Configuration (`.devcontainer/`)

#### `devcontainer.json`
The main VS Code Dev Containers configuration that defines:
- **Base Image**: Ubuntu 22.04
- **Docker Support**: Docker-in-Docker for building and running containers
- **Kubernetes Tools**: kubectl, Helm, Minikube support
- **VS Code Extensions**: Kubernetes, Docker, Git, Language-specific tools
- **Auto-setup**: Runs post-create and post-start scripts automatically

#### `post-create.sh`
Runs once when the container is first created. Installs:
- **Node.js 20** and npm (for frontend and user-simulator)
- **Python 3** and pip (for payment-service and rag-service)
- **Java 17** and Maven (for multiple Java Spring services)
- **.NET 7** SDK (for ad-service and membership-service)
- **Go** (for status-service)
- **PHP** (for like-service)
- **Kubernetes Tools**: Skaffold, Kustomize, Kind
- Full development environment for all 16+ services

#### `post-start.sh`
Runs every time the container starts. Displays helpful information and startup messages.

#### `README.md`
Comprehensive guide covering:
- Prerequisites and setup
- Running with Kubernetes + Skaffold
- Running with Docker Compose
- Available commands
- Security features to test
- Development workflow
- Troubleshooting

### 2. Docker Compose Configuration

#### `docker-compose.demo.yml`
An alternative to Kubernetes for simpler, lighter-weight demos:

**Features:**
- All 16+ Unguard services defined
- Support for profiles (minimal, full, rag)
- Database services: MariaDB, Redis
- Tracing: Jaeger
- Optional: Ollama for RAG service
- Auto-healthchecks
- Named volumes for data persistence
- Isolated bridge network

**Profiles:**
- `full` - All services
- `rag` - RAG-specific services (with Ollama)
- No profile - Core minimal services

### 3. Documentation

#### `QUICKSTART-DEVCONTAINER.md`
Quick start guide with:
- 30-second setup instructions
- Two paths: Kubernetes or Docker Compose
- Service endpoints
- Testing vulnerability examples
- Troubleshooting tips

#### `.env.example`
Environment variable template for configuration:
- Database credentials
- JWT secrets
- Service URLs
- Logging levels
- Feature flags

## 🎯 Use Cases

### For Demos & PoCs
```bash
# Quick demo setup (~2-3 minutes)
docker-compose -f docker-compose.demo.yml --profile full up -d
# Visit http://localhost:3000
```

### For Development
```bash
# Full Kubernetes setup with auto-reload on code changes
kind create cluster --name unguard --config ./k8s-manifests/localdev/kind/cluster-config.yaml
skaffold dev
```

### For Education/Learning
- Includes all programming languages (Java, .NET, Node.js, Python, Go, PHP)
- Pre-installed security testing tools
- Built-in tracing (Jaeger) to understand microservices
- Vulnerability examples with automated exploit toolkit

### For CI/CD Integration
- Reproducible environment via DevContainer
- All dependencies pre-installed
- Works in GitHub Codespaces
- Works locally in VS Code

## 🚀 Getting Started

### Option 1: VS Code (Recommended)
```
1. Install "Dev Containers" extension
2. Open Unguard repo in VS Code
3. Cmd+Shift+P → "Reopen in Container"
4. Wait for setup (~10-15 min first time)
```

### Option 2: Command Line
```bash
# If using devcontainer CLI
devcontainer open

# Or manually with docker
docker build -f .devcontainer -t unguard-dev .
docker run -it --privileged -v /var/run/docker.sock:/var/run/docker.sock unguard-dev
```

### Option 3: GitHub Codespaces
Just push changes and open in Codespaces - it automatically uses the `.devcontainer` config.

## 📋 Directory Structure

```
unguard-codespaces/
├── .devcontainer/                 # DevContainer configuration
│   ├── devcontainer.json          # Main config
│   ├── post-create.sh             # Setup script
│   ├── post-start.sh              # Startup messages
│   └── README.md                  # Detailed docs
├── docker-compose.demo.yml        # Docker Compose alternative
├── .env.example                   # Environment template
├── DEVCONTAINER-SETUP.md          # This file
├── QUICKSTART-DEVCONTAINER.md     # Quick start guide
└── [rest of project...]
```

## 🔧 Key Features

✅ **All Required Languages Pre-installed**
- Node.js, Python, Java, .NET, Go, PHP

✅ **Kubernetes Ready**
- Docker, kubectl, Helm, Skaffold, Kind, Kustomize

✅ **VS Code Integration**
- Extensions for Kubernetes, Docker, language support
- Integrated terminal with all tools available

✅ **Multiple Run Paths**
- Full Kubernetes with Skaffold
- Lightweight Docker Compose
- Flexible for different use cases

✅ **Documentation**
- Quick start (2 min read)
- Detailed setup (comprehensive reference)
- Troubleshooting guide included

✅ **Development Friendly**
- Auto-reload on code changes (with Skaffold)
- Full container rebuild support
- Pre-configured for all 16+ services

## 📊 Performance Considerations

| Aspect | Details |
|--------|---------|
| **Initial Setup** | 10-15 minutes (includes downloads) |
| **Rebuild Services** | 2-5 minutes per service (depends on language) |
| **Docker Compose Startup** | 2-3 minutes for full stack |
| **Kubernetes Startup** | 5-10 minutes after Kind cluster creation |
| **Disk Space** | ~20GB recommended (Docker images + containers) |
| **Memory** | 4GB minimum, 8GB+ recommended |

## 🔐 Security Notes

⚠️ **Unguard is intentionally vulnerable**
- Use only in isolated/sandboxed environments
- Do not expose to the public internet
- Intended for authorized security testing only

The DevContainer includes tools for testing these vulnerabilities:
- SQL Injection testing
- SSRF attacks
- JWT exploitation
- Remote code execution
- And more...

See `exploit-toolkit/exploits/README.md` for details.

## 🆘 Common Issues

### 1. Container fails to build
- Check Docker is running
- Ensure 20GB+ free disk space
- Try `docker system prune` to free space

### 2. Services won't connect
- Check healthchecks: `docker-compose ps`
- View logs: `docker-compose logs <service>`
- Increase Docker memory to 8GB+

### 3. Ports already in use
- Change port mappings in docker-compose.yml
- Or kill existing services: `lsof -i :<port>`

### 4. Kubernetes issues
- Check cluster: `kubectl cluster-info`
- View pods: `kubectl get pods -n unguard`
- Describe pod: `kubectl describe pod -n unguard <pod>`

See `.devcontainer/README.md` for more troubleshooting.

## 📚 Documentation Map

1. **Quick Start** → `QUICKSTART-DEVCONTAINER.md` (read first)
2. **DevContainer Details** → `.devcontainer/README.md` (comprehensive guide)
3. **Development Guide** → `docs/DEV-GUIDE.md` (Skaffold/Kubernetes details)
4. **Security Testing** → `exploit-toolkit/exploits/README.md` (attack scenarios)
5. **Project Overview** → `README.md` (architecture, services)

## 🎓 Learning Resources

The DevContainer includes everything needed to:

- **Learn Microservices**: 16+ services in different languages
- **Learn Docker**: Complete containerization example
- **Learn Kubernetes**: Full K8s deployment on local cluster
- **Learn Security Testing**: Real vulnerable code to practice exploitation
- **Learn Distributed Tracing**: Jaeger integration across services

## 🤝 Contributing

If you improve the DevContainer setup:

1. Test locally first
2. Document changes in comments
3. Update version info in `devcontainer.json` features if using newer versions
4. Test both Docker Compose and Kubernetes paths

## 📝 File Checklist

- ✅ `.devcontainer/devcontainer.json` - VS Code integration
- ✅ `.devcontainer/post-create.sh` - Dependency installation
- ✅ `.devcontainer/post-start.sh` - Welcome messages
- ✅ `.devcontainer/README.md` - Detailed documentation
- ✅ `docker-compose.demo.yml` - Compose alternative
- ✅ `.env.example` - Configuration template
- ✅ `QUICKSTART-DEVCONTAINER.md` - Fast setup guide
- ✅ `DEVCONTAINER-SETUP.md` - This summary

## 🚀 Next Steps

1. **Try the quick start**: Follow `QUICKSTART-DEVCONTAINER.md`
2. **Choose your path**: Kubernetes or Docker Compose
3. **Explore vulnerabilities**: See `exploit-toolkit/exploits/`
4. **Read the docs**: Check `.devcontainer/README.md` for details
5. **Contribute**: Submit improvements or fixes!

---

**Questions?** Check the troubleshooting section in `.devcontainer/README.md` or the detailed development guide in `docs/DEV-GUIDE.md`.
