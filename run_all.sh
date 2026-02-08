#!/bin/bash

# THE MASTER
# Calls everything from start to finish


echo "========================================"
echo " OS Lab Project - tHE Complete Demo"
echo "========================================"
echo ""

if [[ ! -x ./analyze_log ]] || [[ ! -x ./parallel_analyze ]]; then
    echo "Building executables..."
    make all
    echo ""
fi

chmod +x *.sh 2>/dev/null

echo "Press Enter to continue between parts..."
read -p ""

# Part A
echo ""
echo "=== Part A: Environment Setup ==="
./setup_environment.sh
read -p "Press Enter..."

# Part B
echo ""
echo "=== Part B: Log Filtering ==="
./part_b_filtering.sh
read -p "Press Enter..."

# Part C
echo ""
echo "=== Part C: Report Generation ==="
./part_c_pipeline.sh
read -p "Press Enter..."

# Part D
echo ""
echo "=== Part D: Process Management ==="
./part_d_processes.sh
read -p "Press Enter..."

# Part E
echo ""
echo "=== Part E: C Log Analyzer ==="
echo "Testing with system.log:"
./analyze_log monitor/raw/system.log
echo ""
echo "Testing with all logs:"
for log in monitor/raw/*.log; do
    echo "---"
    ./analyze_log "$log"
done
read -p "Press Enter..."

# Part F
echo ""
echo "=== Part F: Automation Script ==="
./run_monitor.sh monitor/raw
read -p "Press Enter..."

# Part G
echo ""
echo "=== Part G: Parallel Analysis ==="
./parallel_analyze monitor/raw/system.log monitor/raw/network.log monitor/raw/security.log
read -p "Press Enter..."

# Summary
echo ""
echo "========================================"
echo " All Parts Complete"
echo "========================================"
echo ""
echo "Generated files:"
find monitor -type f -name "*.log" -o -name "*.txt" 2>/dev/null | sort
echo ""
echo "Project complete!"
