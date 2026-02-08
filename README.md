# OS Lab Project - Event Analysis System

A UNIX-based log monitoring and analysis system for the Operating Systems course.

## Initial Setup

**IMPORTANT: Run this first after extracting the archive!**

```bash
chmod +x setup.sh
./setup.sh
```

This will:
- Make all scripts executable
- Compile the C programs (analyze_log, parallel_analyze)
- Prepare the test generator

## Quick Start

After running setup.sh:

```
os_project/
├── src/                          # All source files
│   ├── setup_environment.sh      # Part A: Creates directory structure and sample logs
│   ├── filter_logs.sh            # Part B: Filters logs using regex
│   ├── generate_report.sh        # Part C: Creates summary reports using pipes
│   ├── manage_processes.sh       # Part D: Demonstrates process management
│   ├── analyze.c                 # Part E: C program for log analysis
│   ├── run_monitor.sh            # Part F: Complete automation script
│   └── parallel_analyze.c        # Part G: Multi-threaded log analyzer
├── tests/                        # Test utilities
│   ├── generator.c               # Generates large test log files
│   └── test.sh                   # Test runner script
├── out/                          # All output files
│   └── monitor/
│       ├── raw/                  # Original log files
│       ├── processed/            # Filtered/processed logs
│       └── reports/              # Generated reports
├── run_all.sh                    # Master script - runs entire workflow
└── README.md                     # This file
```

After running setup.sh:

### Run the complete workflow:
```bash
./run_all.sh
```

### Run with generated test data:
```bash
./run_all.sh --test_size 1000      # Generate 1000 lines per log
./run_all.sh --test_size 10000     # Generate 10000 lines per log
```

## Individual Components

### Part A - Environment Setup
Creates directory structure and sample log files:
```bash
bash src/setup_environment.sh
```

### Part B - Log Filtering
Filters logs for alerts using regex patterns:
```bash
bash src/filter_logs.sh
```

### Part C - Report Generation
Generates daily summary using pipes:
```bash
bash src/generate_report.sh
```

### Part D - Process Management
Demonstrates background processes, priority adjustment, and signals:
```bash
bash src/manage_processes.sh
```

### Part E - C Log Analyzer
Analyzes individual log files:
```bash
gcc -o analyze_log src/analyze.c
./analyze_log out/monitor/raw/system.log
```

Exit codes:
- 0: Success
- 1: File opening error
- 2: Empty file

### Part F - Automation Script
Processes all logs in a directory:
```bash
bash src/run_monitor.sh out/monitor/raw
```

Features:
- Positional parameter validation
- Directory existence checking
- Loop constructs (for, while, case)
- IFS for safe parsing

### Part G - Parallel Analysis
Multi-threaded analysis of multiple log files:
```bash
gcc -pthread -o parallel_analyze src/parallel_analyze.c
./parallel_analyze out/monitor/raw/*.log
```

## Testing

Run the test suite with custom data size:
```bash
cd tests
bash test.sh --test_size 500
```

Or compile and run the generator directly:
```bash
cd tests
gcc -o generator generator.c
./generator 1000
```

## Implementation Details

### Regular Expressions Used
- Date pattern: `^[0-9]{4}-[0-9]{2}-[0-9]{2}`
- Keywords: `ERROR|FAILED|CRITICAL`
- IPv4: `[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}`
- Local network: `192\.168\.`

### Process Management
- Background execution with `&`
- Process discovery with `ps` and `grep`
- Priority adjustment with `renice`
- Graceful termination with `SIGTERM`
- Forced termination with `SIGKILL`

### Thread Safety
- Each thread has its own `thread_data_t` structure
- No shared variables requiring mutex protection
- Uses `pthread_join()` for synchronization

## Output Files

After running, check these files:
- `out/monitor/processed/alerts.sorted` - Filtered and sorted alerts
- `out/monitor/reports/daily_summary.txt` - Summary statistics
- `out/monitor/reports/full_report.txt` - Detailed analysis report

## Requirements

- GCC compiler
- POSIX-compliant shell (bash)
- pthread library
- Standard UNIX utilities (grep, awk, wc, ps, etc.)