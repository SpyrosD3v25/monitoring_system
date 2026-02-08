#!/bin/bash

echo "=== Process Management Demo ==="
echo ""

# Start background process that writes timestamps
echo "1. Starting background process..."
(while true; do 
    date "+%Y-%m-%d %H:%M:%S" >> out/monitor/raw/timestamps.log
    sleep 2
done) &

BG_PID=$!
echo "   Process started with PID: $BG_PID"
sleep 1

# Find process with ps and grep
echo ""
echo "2. Finding process with ps and grep:"
ps aux | grep -E "sleep 2|timestamps" | grep -v grep

# Change priority
echo ""
echo "3. Changing process priority..."
ORIGINAL_NICE=$(ps -o ni= -p $BG_PID)
echo "   Original nice value: $ORIGINAL_NICE"
renice +5 $BG_PID > /dev/null 2>&1
NEW_NICE=$(ps -o ni= -p $BG_PID)
echo "   New nice value: $NEW_NICE"

# Terminate with TERM
echo ""
echo "4. Terminating process with SIGTERM..."
kill -TERM $BG_PID
sleep 1

# Check if still running
if ps -p $BG_PID > /dev/null 2>&1; then
    echo "   Process still running, using SIGKILL..."
    kill -KILL $BG_PID
    echo "   Process killed with SIGKILL"
else
    echo "   Process terminated successfully with SIGTERM"
fi

# Summary
echo ""
echo "5. Summary:"
echo "   PID: $BG_PID"
echo "   Original priority: $ORIGINAL_NICE"
echo "   Modified priority: $NEW_NICE"
echo "   Termination: SIGTERM successful"
echo ""
echo "Timestamps written:"
wc -l out/monitor/raw/timestamps.log
