#!/bin/bash

# Context switching helper script with safety checks

# Function to switch contexts safely
switch_context() {
    local context=$1
    if [ -z "$context" ]; then
        echo "Usage: $0 <context-name>"
        echo ""
        echo "Available contexts:"
        kubectl config get-contexts -o name
        return 1
    fi
    
    if kubectl config get-contexts -o name | grep -q "^${context}$"; then
        echo "🔄 Switching to context: $context"
        kubectl config use-context "$context"
        echo "✅ Switched to context: $context"
        
        echo "🔍 Testing connection..."
        if kubectl cluster-info --request-timeout=5s > /dev/null 2>&1; then
            echo "✅ Cluster is accessible"
            kubectl get nodes 2>/dev/null | head -3
        else
            echo "⚠️  Context exists but cluster may not be accessible"
            echo "💡 For CRC contexts, make sure CRC is running: crc start"
        fi
    else
        echo "❌ Context '$context' not found"
        echo ""
        echo "Available contexts:"
        kubectl config get-contexts
    fi
}

# Special handling for CRC contexts
check_crc() {
    if command -v crc >/dev/null 2>&1; then
        echo "📊 CRC Status:"
        crc status
    else
        echo "💡 CRC command not found. If you want to use CRC, install it first."
    fi
}

# Main logic
case "${1:-}" in
    "crc-admin"|"crc-developer"|"default/api-crc-testing:6443/kubeadmin")
        echo "🔍 Checking CRC status first..."
        check_crc
        echo ""
        if crc status 2>/dev/null | grep -q "OpenShift:.*Running"; then
            switch_context "$1"
        else
            echo "⚠️  CRC is not running. Start it with: crc start"
            echo "Do you want to start CRC now? (y/n)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                echo "🚀 Starting CRC..."
                crc start
                switch_context "$1"
            fi
        fi
        ;;
    "kind-kind")
        echo "🔍 Checking Kind cluster..."
        if kind get clusters 2>/dev/null | grep -q "kind"; then
            switch_context "$1"
        else
            echo "⚠️  Kind cluster not found. Create one with: kind create cluster"
        fi
        ;;
    "list"|"--list"|"-l")
        echo "📋 Available contexts:"
        kubectl config get-contexts
        echo ""
        echo "Current context: $(kubectl config current-context)"
        ;;
    "current"|"--current")
        echo "Current context: $(kubectl config current-context)"
        kubectl cluster-info --request-timeout=5s 2>/dev/null || echo "⚠️  Current context may not be accessible"
        ;;
    "help"|"--help"|"-h"|"")
        echo "🔧 Context Switching Helper"
        echo ""
        echo "Usage: $0 <command|context-name>"
        echo ""
        echo "Commands:"
        echo "  list, -l        Show all available contexts"
        echo "  current         Show current context and test connection"  
        echo "  help, -h        Show this help"
        echo ""
        echo "Context Examples:"
        echo "  $0 kind-kind"
        echo "  $0 crc-admin"
        echo "  $0 crc-developer"
        echo ""
        echo "Available contexts:"
        kubectl config get-contexts -o name | sed 's/^/  /'
        ;;
    *)
        switch_context "$1"
        ;;
esac
