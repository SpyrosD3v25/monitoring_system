#!/bin/bash

# Check for argument
if [ $# -eq 0 ]; then
    echo "Error: No directory specified"
    echo "Usage: $0 <log_directory>"
    exit 1
fi

LOG_DIR="$1"

# Check if directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory '$LOG_DIR' does not exist"
    exit 1
fi

# Display script info
echo "Script name: $0"
echo "Total arguments: $#"
echo "Processing directory: $LOG_DIR"
echo ""

# Compile analyze.c if needed
if [ ! -f "analyze_log" ] || [ "src/analyze.c" -nt "analyze_log" ]; then
    echo "Compiling analyze.c..."
    gcc -o analyze_log src/analyze.c
    chmod +x analyze_log
    if [ $? -ne 0 ]; then
        echo "Error: Failed to compile analyze.c"
        exit 1
    fi
fi

# Initialize report
REPORT_FILE="out/monitor/reports/full_report.txt"
echo "=== Full Log Analysis Report ===" > "$REPORT_FILE"
echo "Generated: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Process each log file
for logfile in "$LOG_DIR"/*.log; do
    if [ -f "$logfile" ]; then
        echo "Processing: $logfile"
        
        # Determine log category using case
        basename=$(basename "$logfile")
        case "$basename" in
            system*)
                category="SYSTEM"
                ;;
            network*)
                category="NETWORK"
                ;;
            security*)
                category="SECURITY"
                ;;
            *)
                category="GENERAL"
                ;;
        esac
        
        echo "" >> "$REPORT_FILE"
        echo "[$category LOG] $basename" >> "$REPORT_FILE"
        echo "-----------------------------------" >> "$REPORT_FILE"
        
        # Run analysis
        ./analyze_log "$logfile" >> "$REPORT_FILE" 2>&1
        
        # Check exit code
        exit_code=$?
        case $exit_code in
            0)
                echo "Analysis completed successfully"
                ;;
            1)
                echo "Error opening file"
                ;;
            2)
                echo "File is empty"
                ;;
            *)
                echo "Unknown error (code: $exit_code)"
                ;;
        esac
        
        echo "" >> "$REPORT_FILE"
    fi
done

# Add summary with while loop
echo "" >> "$REPORT_FILE"
echo "=== Summary ===" >> "$REPORT_FILE"

total_lines=0
total_errors=0

# Read report and sum up statistics
while IFS= read -r line; do
    if [[ "$line" =~ Total\ lines:\ ([0-9]+) ]]; then
        total_lines=$((total_lines + ${BASH_REMATCH[1]}))
    fi
    if [[ "$line" =~ Lines\ with\ ERROR:\ ([0-9]+) ]]; then
        total_errors=$((total_errors + ${BASH_REMATCH[1]}))
    fi
done < "$REPORT_FILE"

echo "Total lines processed: $total_lines" >> "$REPORT_FILE"
echo "Total errors found: $total_errors" >> "$REPORT_FILE"

echo ""
echo "Report generated: $REPORT_FILE"
cat "$REPORT_FILE"
