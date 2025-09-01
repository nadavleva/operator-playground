# ObjStore Kubernetes Operator

A Kubernetes operator for managing ObjStore resources built with Kubebuilder and Go.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Kind Cluster Setup](#kind-cluster-setup)
- [Development Workflow](#development-workflow)
- [Using the Operator](#using-the-operator)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)

## Overview

This operator manages `ObjStore` custom resources with the following features:

- **State Management**: Automatically sets initial state to `PENDING` for new resources
- **Validation**: Enforces minimum name length of 4 characters  
- **Status Tracking**: Provides state field in resource status
- **Print Columns**: Shows state when using `kubectl get objstore`

## Prerequisites

- Go 1.24.5 or later
- kubectl
- Kind (Kubernetes in Docker)
- Docker or Podman

## Getting Started

### 1. Clone and Setup

```bash
git clone <your-repo>
cd cninf
```

### 2. Build the Operator

```bash
make build
```

## Kind Cluster Setup

### Create a Kind Cluster

```bash
# Create a new kind cluster
kind create cluster

# Verify cluster is running
kubectl cluster-info
```

### Connect to Existing Kind Cluster

If you have an existing kind cluster but kubectl isn't connected:

```bash
# List available kind clusters
kind get clusters

# Export kubeconfig for the cluster
kind export kubeconfig --name=kind

# Verify connection
kubectl cluster-info
kubectl get nodes
```

### Switch Between Contexts

```bash
# List all available contexts
kubectl config get-contexts

# Switch to kind cluster context
kubectl config use-context kind-kind

# Switch to CRC contexts (check if CRC is running first)
crc status
# If CRC is running, you can use:
kubectl config use-context crc-admin           # Admin user
kubectl config use-context crc-developer       # Developer user
# Or: kubectl config use-context default/api-crc-testing:6443/kubeadmin
```

### Context Management Helper

Create a simple script to check and switch contexts safely:

```bash
# Check current context
kubectl config current-context

# Helper function to switch contexts safely
switch_context() {
    local context=$1
    if kubectl config get-contexts -o name | grep -q "^${context}$"; then
        kubectl config use-context "$context"
        echo "✅ Switched to context: $context"
        kubectl cluster-info --request-timeout=5s || echo "⚠️  Context exists but cluster may not be accessible"
    else
        echo "❌ Context '$context' not found"
        echo "Available contexts:"
        kubectl config get-contexts -o name
    fi
}

# Usage examples:
# switch_context kind-kind
# switch_context crc-admin
```

## Development Workflow

This project includes several convenient development scripts:

### 🔄 Full Development Cycle

```bash
./scripts/dev-restart.sh
```
- Stops any running controller processes
- Clears port conflicts (8081)
- Rebuilds the controller
- Starts controller in background
- Saves PID for easy management
- Redirects logs to `controller.log`

### 🛑 Stop Controller

```bash
./scripts/stop-controller.sh
```
- Cleanly stops the running controller using saved PID
- Fallback process cleanup by name

### 🔨 Build Only

```bash
./scripts/rebuild.sh
```
- Rebuilds the controller binary only
- Does not start the controller

### 📋 View Logs

```bash
./scripts/logs.sh
```
- Shows real-time controller logs
- Use Ctrl+C to exit log viewing

### 🔄 Switch Contexts Safely

```bash
./scripts/switch-context.sh <context-name>
```
- Safely switches between Kubernetes contexts with validation
- Checks if clusters are running before switching
- Provides helpful error messages and suggestions

Examples:
```bash
./scripts/switch-context.sh kind-kind        # Switch to kind cluster
./scripts/switch-context.sh crc-admin        # Switch to CRC admin (checks if CRC is running)
./scripts/switch-context.sh list             # Show all contexts
./scripts/switch-context.sh current          # Show current context and test connection
```

### Manual Operations

```bash
# Start controller manually (foreground)
./bin/manager

# Start controller manually (background)
nohup ./bin/manager > controller.log 2>&1 &

# View recent logs
tail -n 50 controller.log

# Follow logs in real-time
tail -f controller.log
```

## Using the Operator

### 1. Install CRDs

```bash
# Install Custom Resource Definitions
kubectl apply -f config/crd/bases/

# Verify CRDs are installed
kubectl get crds | grep objstore
```

### 2. Start the Controller

```bash
# Development mode (runs locally, connects to cluster)
./scripts/dev-restart.sh
```

### 3. Create ObjStore Resources

```bash
# Apply sample resource
kubectl apply -f config/samples/cninf_v1alpha1_objstore.yaml

# Create custom resource
cat <<EOF | kubectl apply -f -
apiVersion: cninf.nadavleva.github.io/v1alpha1
kind: ObjStore
metadata:
  name: my-objstore
  namespace: default
spec:
  name: "my-object-store"
  locked: false
EOF
```

### 4. Monitor Resources

```bash
# List ObjStore resources (shows State column)
kubectl get objstore

# Describe a specific resource
kubectl describe objstore my-objstore

# Watch for changes
kubectl get objstore -w
```

## API Reference

### ObjStore Spec

```yaml
apiVersion: cninf.nadavleva.github.io/v1alpha1
kind: ObjStore
metadata:
  name: example-objstore
spec:
  name: "example-store"    # Required, minimum 4 characters
  locked: false           # Optional, prevents deletion when true
```

### State Constants

The operator uses the following state constants:

- `PENDING`: Initial state for new resources
- `CREATING`: Resource is being created
- `CREATED`: Resource successfully created  
- `ERROR`: Error occurred during processing

### Validation Rules

- **name**: Must be at least 4 characters long
- **locked**: Optional boolean field

## Troubleshooting

### Common Issues

#### 1. Port 8081 Already in Use

**Error**: `error listening on :8081: bind: address already in use`

**Solution**: 
```bash
# The dev-restart.sh script automatically handles this, but manually:
lsof -i :8081
kill <PID>
```

#### 2. Cannot Connect to Cluster

**Error**: `connection refused` to API server

**Solution**:
```bash
# Check if kind cluster is running
kind get clusters

# Export kubeconfig
kind export kubeconfig --name=kind

# Verify connection
kubectl cluster-info
```

#### 3. Controller Logs Show Connection Errors

**Error**: `failed to get server groups`

**Solution**: Check kubectl context
```bash
kubectl config current-context
kubectl config use-context kind-kind
```

#### 4. CRD Not Found

**Error**: `no matches for kind "ObjStore"`

**Solution**: Install CRDs first
```bash
kubectl apply -f config/crd/bases/
```

### Log Debugging

```bash
# Check controller logs
./logs.sh

# Or manually
tail -f controller.log

# Check specific errors
grep ERROR controller.log
```

### Process Management

```bash
# Check if controller is running
ps aux | grep manager

# Check saved PID
cat .manager.pid

# Kill by PID file
kill $(cat .manager.pid)
```

### Development Tips

1. **Always use `./scripts/dev-restart.sh`** for the fastest development cycle
2. **Check logs with `./scripts/logs.sh`** when debugging issues  
3. **Use `kubectl get objstore -w`** to watch resource changes in real-time
4. **Clean up resources** with `kubectl delete objstore --all` between tests
5. **Verify CRDs** are up-to-date after API changes with `make manifests`

## File Structure

```
├── api/v1alpha1/           # API definitions
│   ├── objstore_types.go   # ObjStore resource definition
│   └── ...
├── config/                 # Kubernetes manifests
│   ├── crd/bases/         # Custom Resource Definitions
│   ├── samples/           # Example resources
│   └── ...
├── internal/controller/    # Controller logic
│   └── objstore_controller.go
├── cmd/main.go            # Application entry point
├── bin/                   # Built binaries
├── controller.log         # Controller logs (when running)
├── .manager.pid          # Saved process ID
├── scripts/              # Development scripts
│   ├── dev-restart.sh    # Full development cycle
│   ├── stop-controller.sh # Stop controller
│   ├── rebuild.sh        # Build only
│   ├── logs.sh           # View logs
│   ├── switch-context.sh # Safe context switching
│   └── scripts.sh        # Main project scripts history
└── README.md           # This file
```

## Next Steps

- Deploy operator to cluster using `make deploy`
- Add webhook validation
- Implement more complex controller logic
- Add metrics and observability
- Write comprehensive tests

---

For more information about Kubebuilder, visit: https://kubebuilder.io/