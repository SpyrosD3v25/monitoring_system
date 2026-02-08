#!/bin/bash

# Filter logs for alerts using grep with regex
grep -hE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' out/monitor/raw/*.log | \
grep -E 'ERROR|FAILED|CRITICAL' > out/monitor/processed/alerts.raw

# Also capture lines with IPv4 addresses
grep -hE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' out/monitor/raw/*.log | \
grep -E 'ERROR|FAILED|CRITICAL' >> out/monitor/processed/alerts.raw

# Remove duplicates and sort
sort -u out/monitor/processed/alerts.raw > out/monitor/processed/alerts.sorted

echo "Filtered alerts created:"
echo "  Raw alerts: $(wc -l < out/monitor/processed/alerts.raw)"
echo "  Sorted unique alerts: $(wc -l < out/monitor/processed/alerts.sorted)"
