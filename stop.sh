#!/bin/sh
# stop.sh — Clean shutdown of the backend
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PIDFILE="$SCRIPT_DIR/output/api.pid"

if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        echo "Stopped bonfyre-api (PID $PID)"
    else
        echo "Process $PID not running"
    fi
    rm -f "$PIDFILE"
else
    echo "No PID file found. Backend may not be running."
fi
