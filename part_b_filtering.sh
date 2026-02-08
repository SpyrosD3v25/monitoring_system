#!/bin/bash

# Part B: Filter logs using regular expressions
# Extract lines with dates, error keywords, and IP addresses

echo "========================================="
echo "  Part B: Log Filtering with Regex"
echo "========================================="
echo ""

cd monitor 2>/dev/null || { echo "ERROR: Run this from project root"; exit 1; }

echo "[1] Filtering logs for important events..."
echo ""
echo "Looking for:"
echo "  - Date patterns (YYYY-MM-DD)"
echo "  - Error keywords (ERROR, FAILED, CRITICAL)"
echo "  - IPv4 addresses"
echo ""

mkdir -p processed

# Use grep with extended regex to find matching lines
# The pattern matches any line containing:
#   - A date at the start (four digits, dash, two digits, dash, two digits)
#   - OR the words ERROR, FAILED, or CRITICAL
#   - OR an IP address (four groups of 1-3 digits separated by dots)
grep -hE '(^[0-9]{4}-[0-9]{2}-[0-9]{2}|ERROR|FAILED|CRITICAL|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' \
    raw/*.log > processed/alerts.raw 2>/dev/null || true

raw_count=$(wc -l < processed/alerts.raw)
echo "Found $raw_count matching lines"
echo "Saved to processed/alerts.raw"
echo ""

# Remove duplicates and sort
echo "[2] Removing duplicates and sorting..."
sort -u processed/alerts.raw > processed/alerts.sorted

sorted_count=$(wc -l < processed/alerts.sorted)
duplicates=$((raw_count - sorted_count))
echo "Removed $duplicates duplicates"
echo "Final count: $sorted_count unique alerts"
echo "Saved to processed/alerts.sorted"
echo ""

echo "[3] First 10 alerts:"
echo "---"
head -10 processed/alerts.sorted
echo "..."
echo ""

echo "========================================="
echo "  Part B Complete"
echo "========================================="

