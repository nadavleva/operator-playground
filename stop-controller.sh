#!/bin/bash

# Script to stop the running controller

echo "🛑 Stopping controller..."

# Method 1: Stop using saved PID file
if [ -f .manager.pid ]; then
    PID=$(cat .manager.pid)
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        echo "Controller with PID $PID stopped"
        rm .manager.pid
    else
        echo "PID $PID not running, removing stale PID file"
        rm .manager.pid
    fi
else
    echo "No .manager.pid file found"
fi

# Method 2: Stop any manager processes by name
if pkill -f "bin/manager"; then
    echo "Stopped remaining manager processes"
else
    echo "No running manager processes found"
fi

echo "✅ Controller stopped"
