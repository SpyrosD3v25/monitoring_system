# Operating Systems Lab Project

Log monitoring and analysis system for UNIX environments.

## Project Structure

```
os_project/
├── src/
│   ├── analyze.c              - Single-threaded log analyzer (Part E)
│   └── parallel_analyze.c     - Multi-threaded analyzer (Part G)
├── monitor/
│   ├── raw/                   - Input log files
│   ├── processed/             - Filtered data
│   └── reports/               - Generated reports
├── setup_environment.sh       - Part A: Create directories and sample logs
├── part_b_filtering.sh        - Part B: Filter logs with regex
├── part_c_pipeline.sh         - Part C: Generate reports with pipes
├── part_d_processes.sh        - Part D: Process management demo
├── run_monitor.sh             - Part F: Automation script
├── run_all.sh                 - Run everything in sequence
├── Makefile                   - Build system
└── README.md                  - This file
```

## Quick Start

### Build

```bash
make all
```

This compiles both C programs:
- `analyze_log` - Single-threaded analyzer
- `parallel_analyze` - Multi-threaded analyzer

### Run Everything

```bash
./run_all.sh
```

Runs all parts (A through G) in sequence.

### Run Individual Parts

```bash
# Part A: Setup environment
./setup_environment.sh

# Part B: Filter logs
./part_b_filtering.sh

# Part C: Generate report
./part_c_pipeline.sh

# Part D: Process management
./part_d_processes.sh

# Part E: Analyze single file
./analyze_log monitor/raw/system.log

# Part F: Analyze all files
./run_monitor.sh monitor/raw

# Part G: Parallel analysis
./parallel_analyze monitor/raw/*.log
```

## Requirements

- Linux (Ubuntu, Debian, Fedora, etc.)
- GCC compiler
- Standard UNIX utilities (grep, awk, sed, wc)
- POSIX threads library

## Project Components

### Part A - Environment Setup (0.5 points)
Creates directory structure and generates sample log files with dates, error keywords, and IP addresses.

### Part B - Regex Filtering (0.5 points)
Uses grep with extended regex to filter logs for:
- Date patterns (YYYY-MM-DD)
- Error keywords (ERROR, FAILED, CRITICAL)
- IPv4 addresses

Removes duplicates and sorts the results.

### Part C - Pipes and Redirection (0.5 points)
Single pipeline command that counts total alerts, errors, and local network events using command substitution and redirects.

### Part D - Process Management (0.4 points)
Demonstrates:
- Background process creation
- Process identification with ps and grep
- Priority changes with nice/renice
- Signal handling (SIGTERM, SIGKILL)

### Part E - C Log Analyzer (0.6 points)
Program features:
- Opens files with open() system call
- Error handling with errno and perror()
- Counts lines, ERROR keywords, and numbers
- Returns proper exit codes (0=ok, 1=error, 2=empty)

### Part F - Shell Script Automation (0.7 points)
Automation script with:
- Argument validation
- Directory checking
- For loops for file iteration
- Case statements for log categorization
- While loops with IFS for safe processing
- Comprehensive report generation

### Part G - Multi-threaded Analysis (0.8 points)
Parallel analyzer using POSIX threads:
- Creates one thread per file
- Each thread has its own data structure (thread-safe)
- Uses pthread_join for synchronization
- Aggregates results after all threads complete

## Building

### Compile Everything
```bash
make all
```

### Compile Individually
```bash
gcc -Wall -Wextra -O2 src/analyze.c -o analyze_log
gcc -Wall -Wextra -O2 -pthread src/parallel_analyze.c -o parallel_analyze
```

### Clean
```bash
make clean
```

## Example Usage

### Analyze a Single Log
```bash
./analyze_log monitor/raw/system.log

=== Log Analysis Results ===
File: monitor/raw/system.log
Total lines: 12
Lines with ERROR: 4
Lines with numbers: 12
===========================
```

### Parallel Analysis
```bash
./parallel_analyze monitor/raw/*.log

=== Parallel Log Analysis ===
Processing 3 file(s) with threads...

=== Individual File Results ===
File: monitor/raw/network.log | Lines:     12 | Errors:      3
File: monitor/raw/security.log | Lines:     12 | Errors:      3
File: monitor/raw/system.log   | Lines:     12 | Errors:      4

=== Global Summary ===
TOTAL LINES:        36
TOTAL ERRORS:       10
Files Processed:    3
Files Failed:       0
=====================
```

## Exit Codes

- `0` - Success
- `1` - File open error or processing failure
- `2` - Empty file (warning)

## Notes

All scripts should be executable:
```bash
chmod +x *.sh
```

The project includes sample log files with realistic data patterns for testing.

## License

Academic project for educational purposes.
