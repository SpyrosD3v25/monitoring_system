#!/bin/bash

# Part F: Automation script to analyze all log files in a directory
# Uses the analyze_log program on each file and generates a report

set -u
set -o pipefail

script_name=$(basename "$0")
report_file="reports/full_report.txt"

show_usage() {
    cat << EOF
Usage: $script_name <log_directory>

Analyzes all log files in the specified directory and generates a report.

Example:
    $script_name raw/
    $script_name /path/to/logs/

EOF
}

# Figure out what type of log this is based on the filename
categorize_log() {
    local filename="$1"
    local category="GENERAL"
    
    case "$filename" in
        *system*) category="SYSTEM" ;;
        *network*) category="NETWORK" ;;
        *security*) category="SECURITY" ;;
        *application*|*app*) category="APPLICATION" ;;
        *error*) category="ERROR" ;;
    esac
    
    echo "$category"
}

analyze_file() {
    local logfile="$1"
    local category="$2"
    local analyzer="./analyze_log"
    
    if [[ ! -x "$analyzer" ]]; then
        echo "ERROR: $analyzer not found or not executable" >&2
        return 1
    fi
    
    echo "[Processing] $logfile (Category: $category)"
    
    local result
    result=$("$analyzer" "$logfile" 2>&1)
    local exit_code=$?
    
    case $exit_code in
        0)
            echo "[OK] $logfile"
            echo "$result"
            ;;
        1)
            echo "[FAILED] $logfile - Could not open file"
            echo "$result"
            ;;
        2)
            echo "[WARNING] $logfile - Empty file"
            echo "$result"
            ;;
        *)
            echo "[ERROR] $logfile - Unknown error (code: $exit_code)"
            ;;
    esac
    
    echo "---"
    return $exit_code
}

echo "========================================"
echo "  Log Monitoring System"
echo "========================================"
echo ""

echo "Script: $script_name"
echo "Arguments: $#"
echo ""

if [[ $# -eq 0 ]]; then
    echo "ERROR: No directory specified" >&2
    echo ""
    show_usage
    exit 1
fi

log_dir="$1"

if [[ ! -d "$log_dir" ]]; then
    echo "ERROR: Directory does not exist: $log_dir" >&2
    exit 1
fi

if [[ ! -r "$log_dir" ]]; then
    echo "ERROR: Directory is not readable: $log_dir" >&2
    exit 1
fi

mkdir -p "$(dirname "$report_file")"

{
    echo "====================================="
    echo "  Log Analysis Report"
    echo "  Generated: $(date)"
    echo "  Directory: $log_dir"
    echo "====================================="
    echo ""
} > "$report_file"

file_count=0
success_count=0
failed_count=0
empty_count=0

while IFS= read -r -d '' logfile; do
    ((file_count++))
    
    category=$(categorize_log "$(basename "$logfile")")
    
    {
        echo "File $file_count: $(basename "$logfile")"
        echo "Category: $category"
        echo "Path: $logfile"
        echo ""
    } >> "$report_file"
    
    # Analyze the file
    output=$(analyze_file "$logfile" "$category" 2>&1)
    code=$?
    
    # Append results to report
    echo "$output" >> "$report_file"
    echo "" >> "$report_file"
    
    # Update counters
    case $code in
        0) ((success_count++)) ;;
        1) ((failed_count++)) ;;
        2) ((empty_count++)) ;;
    esac
    
done < <(find "$log_dir" -type f -name "*.log" -print0)

# Handle case where no logs were found
if [[ $file_count -eq 0 ]]; then
    echo "WARNING: No .log files found in $log_dir"
    echo "No log files found" >> "$report_file"
    exit 0
fi

# Add summary to report
{
    echo "====================================="
    echo "  Summary"
    echo "====================================="
    echo "Total files: $file_count"
    echo "Successful: $success_count"
    echo "Failed: $failed_count"
    echo "Empty: $empty_count"
    echo ""
    echo "Report: $report_file"
} | tee -a "$report_file"

echo ""
echo "Analysis complete"
echo "Full report saved to: $report_file"

# Exit with error if any files failed
if [[ $failed_count -gt 0 ]]; then
    exit 1
else
    exit 0
fi

