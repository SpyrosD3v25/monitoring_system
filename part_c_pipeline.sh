#!/bin/bash

# Part C: Use pipes and redirection to generate a summary report
# Counts total alerts, errors, and local network events

echo "========================================="
echo "  Part C: Pipeline Report Generation"
echo "========================================="
echo ""

cd monitor 2>/dev/null || { echo "ERROR: Run this from project root"; exit 1; }

if [[ ! -f processed/alerts.sorted ]]; then
    echo "ERROR: processed/alerts.sorted not found"
    echo "Run part_b_filtering.sh first"
    exit 1
fi

mkdir -p reports

echo "[1] Generating summary report..."
echo ""

# Count statistics using command substitution and redirects
{
    total=$(wc -l < processed/alerts.sorted)
    errors=$(grep -c "ERROR" processed/alerts.sorted || echo 0)
    local_net=$(grep -cE "192\.168\.[0-9]{1,3}\.[0-9]{1,3}" processed/alerts.sorted || echo 0)
    echo "Total Alerts: $total, Errors: $errors, Local Network Events: $local_net"
} > reports/daily_summary.txt

echo "Report generated:"
echo "---"
cat reports/daily_summary.txt
echo "---"
echo ""

echo "[2] Detailed breakdown:"
echo ""

echo "Alerts by severity:"
grep -oE "ERROR|FAILED|CRITICAL" processed/alerts.sorted | sort | uniq -c | \
    awk '{printf "  %-10s: %d\n", $2, $1}'
echo ""

echo "Most common IP addresses:"
grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" processed/alerts.sorted | \
    sort | uniq -c | sort -rn | head -5 | awk '{printf "  %s (%d times)\n", $2, $1}'
echo ""

echo "========================================="
echo "  Part C Complete"
echo "========================================="
