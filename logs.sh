#!/bin/bash

# Script to view controller logs in real-time

if [ -f controller.log ]; then
    echo "📋 Showing controller logs (Press Ctrl+C to exit)..."
    echo "================================"
    tail -f controller.log
else
    echo "❌ No controller.log file found. Controller may not be running."
    echo "Start the controller with: ./dev-restart.sh"
fi
