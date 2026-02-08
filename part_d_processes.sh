#!/bin/bash

# Part D: Process management demonstration
# Creates a background process, changes its priority, and terminates it

echo "========================================="
echo "  Part D: Process Management"
echo "========================================="
echo ""

cd monitor 2>/dev/null || { echo "ERROR: Run this from project root"; exit 1; }

# Start a background process that writes timestamps
echo "[1] Starting background process..."

(
    while true; do
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Timestamp from PID $$" >> raw/timestamps.log
        sleep 2
    done
) &

bg_pid=$!
echo "Started background process with PID: $bg_pid"
echo ""

sleep 1

# Find the process using ps and grep
echo "[2] Locating process..."
ps_line=$(ps aux | grep "$bg_pid" | grep -v grep || echo "")
if [[ -n "$ps_line" ]]; then
    echo "Found process:"
    echo "$ps_line"
else
    echo "Process not found in ps output"
fi
echo ""

# Change process priority
echo "[3] Changing process priority..."
old_nice=$(ps -o ni= -p "$bg_pid" 2>/dev/null || echo "unknown")
echo "Current nice value: $old_nice"

renice -n 10 -p "$bg_pid" > /dev/null 2>&1 || echo "Note: renice may require root"

new_nice=$(ps -o ni= -p "$bg_pid" 2>/dev/null || echo "unknown")
echo "New nice value: $new_nice"
echo ""

echo "[4] Letting process run for 5 seconds..."
sleep 5
line_count=$(wc -l < raw/timestamps.log 2>/dev/null || echo 0)
echo "Process wrote $line_count timestamps"
echo ""

echo "[5] Terminating process..."
echo ""

echo "  Sending SIGTERM (graceful shutdown)..."
kill -TERM "$bg_pid" 2>/dev/null && {
    echo "  SIGTERM sent"
    sleep 1
    
    if ps -p "$bg_pid" > /dev/null 2>&1; then
        echo "  Process still running, sending SIGKILL..."
        kill -KILL "$bg_pid" 2>/dev/null
        echo "  SIGKILL sent"
    else
        echo "  Process terminated successfully"
    fi
} || {
    echo "  Process already terminated"
}

sleep 1
if ps -p "$bg_pid" > /dev/null 2>&1; then
    echo "  WARNING: Process still running"
else
    echo "  Process terminated"
fi
echo ""

echo "[6] Summary:"
echo "---"
echo "PID: $bg_pid"
echo "Initial nice: $old_nice"
echo "Modified nice: $new_nice"
echo "Timestamps written: $(wc -l < raw/timestamps.log)"
echo "Status: Terminated"
echo "---"
echo ""

echo "Sample timestamps:"
head -5 raw/timestamps.log
echo ""

echo "========================================="
echo "  Part D Complete"
echo "========================================="
