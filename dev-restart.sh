#!/bin/bash

# Development script to stop, rebuild, and restart the controller

set -e  # Exit on any error

echo "🛑 Stopping any running controller processes..."
# Find and kill any running manager processes
pkill -f "bin/manager" || echo "No running manager processes found"

# Check for processes using port 8081 (webhook server port)
echo "🔍 Checking for processes using port 8081..."
PORT_USERS=$(lsof -t -i :8081 2>/dev/null || true)
if [ -n "$PORT_USERS" ]; then
    echo "Found processes using port 8081: $PORT_USERS"
    echo "Killing processes to free the port..."
    kill $PORT_USERS 2>/dev/null || true
    sleep 1
    echo "Port 8081 freed"
else
    echo "Port 8081 is available"
fi

echo "🔨 Rebuilding controller..."
make build

echo "🚀 Starting controller in background..."
# Run in the background and save PID for easy stopping later
nohup ./bin/manager > controller.log 2>&1 &
MANAGER_PID=$!
echo "Controller started with PID: $MANAGER_PID"
echo "To stop the controller later, run: ./stop-controller.sh"

# Save the PID to a file for later reference
echo $MANAGER_PID > .manager.pid
echo "PID saved to .manager.pid file"
echo "Logs are being written to: controller.log"

echo "✅ Controller is running in background. Check logs with: tail -f controller.log"
