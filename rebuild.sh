#!/bin/bash

# Script to just rebuild the controller

set -e  # Exit on any error

echo "🔨 Rebuilding controller..."
make build

echo "✅ Controller rebuilt successfully!"
echo "Binary is ready at: ./bin/manager"
echo ""
echo "To run: ./bin/manager"
echo "Or use: ./dev-restart.sh to stop, rebuild, and restart"
