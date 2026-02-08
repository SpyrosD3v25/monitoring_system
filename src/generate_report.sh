#!/bin/bash

# Single pipeline to generate report
cat out/monitor/processed/alerts.sorted | \
awk '
BEGIN {
    total = 0
    errors = 0
    local_net = 0
}
{
    total++
    if (/ERROR/) errors++
    if (/192\.168\./) local_net++
}
END {
    printf "Total Alerts: %d, Errors: %d, Local Network Events: %d\n", total, errors, local_net
}
' > out/monitor/reports/daily_summary.txt

cat out/monitor/reports/daily_summary.txt
