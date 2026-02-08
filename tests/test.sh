#!/bin/bash

TEST_SIZE=${1:-100}

if [[ "$1" == "--test_size" ]]; then
    TEST_SIZE=$2
fi

echo "=== Test Suite for OS Project ==="
echo "Generating test data with $TEST_SIZE lines per log..."
echo ""

# Compile and run generator
cd tests
gcc -o generator generator.c
./generator $TEST_SIZE
cd ..

echo ""
echo "=== Running all components ==="
echo ""

# Run all parts
bash src/setup_environment.sh
echo ""
bash src/filter_logs.sh
echo ""
bash src/generate_report.sh
echo ""
bash src/manage_processes.sh
echo ""

# Compile and test C programs
gcc -o analyze_log src/analyze.c
gcc -pthread -o parallel_analyze src/parallel_analyze.c

echo ""
echo "=== Testing analyze_log ==="
./analyze_log out/monitor/raw/system.log
echo ""

echo "=== Testing parallel_analyze ==="
./parallel_analyze out/monitor/raw/*.log
echo ""

echo "=== Testing run_monitor.sh ==="
bash src/run_monitor.sh out/monitor/raw
