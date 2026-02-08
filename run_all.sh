#!/bin/bash

echo "========================================="
echo "   OS Project - Complete Workflow"
echo "========================================="
echo ""

# Check for test_size flag
if [[ "$1" == "--test_size" ]] && [[ -n "$2" ]]; then
    echo "Generating test data with $2 lines per log..."
    cd tests
    gcc -o generator generator.c 2>/dev/null
    ./generator $2
    cd ..
    echo ""
fi

echo "=== Part A: Environment Setup ==="
bash src/setup_environment.sh
echo ""

echo "=== Part B: Log Filtering ==="
bash src/filter_logs.sh
echo ""

echo "=== Part C: Report Generation ==="
bash src/generate_report.sh
echo ""

echo "=== Part D: Process Management ==="
bash src/manage_processes.sh
echo ""

echo "=== Part E: C Program - analyze_log ==="
if [ ! -f "analyze_log" ] || [ "src/analyze.c" -nt "analyze_log" ]; then
    echo "Compiling analyze.c..."
    gcc -o analyze_log src/analyze.c
    chmod +x analyze_log
fi
./analyze_log out/monitor/raw/system.log
echo ""

echo "=== Part F: Automation Script ==="
bash src/run_monitor.sh out/monitor/raw
echo ""

echo "=== Part G: Parallel Analysis ==="
if [ ! -f "parallel_analyze" ] || [ "src/parallel_analyze.c" -nt "parallel_analyze" ]; then
    echo "Compiling parallel_analyze.c..."
    gcc -pthread -o parallel_analyze src/parallel_analyze.c
    chmod +x parallel_analyze
fi
./parallel_analyze out/monitor/raw/*.log
echo ""

echo "========================================="
echo "   Workflow Complete!"
echo "========================================="
echo ""
echo "Output files created:"
echo "  - out/monitor/processed/alerts.sorted"
echo "  - out/monitor/reports/daily_summary.txt"
echo "  - out/monitor/reports/full_report.txt"
