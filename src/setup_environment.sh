#!/bin/bash

# Create directory structure
mkdir -p out/monitor/{raw,processed,reports}

# Only create sample logs if they don't exist or are empty
if [ ! -s out/monitor/raw/system.log ]; then
    # Create log files with sample data
cat > out/monitor/raw/system.log << 'EOF'
2025-01-15 10:23:45 System startup completed
2025-01-15 10:24:12 ERROR: Disk space running low on /dev/sda1
2025-01-15 10:25:33 Service httpd started successfully
2025-01-15 10:26:01 WARNING: High CPU usage detected
2025-01-15 10:27:18 CRITICAL: Memory threshold exceeded at 192.168.1.100
2025-01-15 10:28:45 INFO: Backup completed
2025-01-15 10:29:22 FAILED: Database connection to 10.0.0.50
2025-01-15 10:30:11 System check passed
EOF

cat > out/monitor/raw/network.log << 'EOF'
2025-01-15 10:20:01 Connection established from 192.168.1.15
2025-01-15 10:21:14 ERROR: Timeout connecting to 8.8.8.8
2025-01-15 10:22:33 Packet loss detected on interface eth0
2025-01-15 10:23:47 CRITICAL: Port scan detected from 203.0.113.42
2025-01-15 10:24:55 Network traffic normal
2025-01-15 10:25:12 FAILED: DNS resolution for example.com
2025-01-15 10:26:30 Firewall rule applied for 192.168.1.0/24
2025-01-15 10:27:08 Connection closed 172.16.0.5
EOF

cat > out/monitor/raw/security.log << 'EOF'
2025-01-15 09:15:22 User login: admin from 192.168.1.50
2025-01-15 09:16:45 FAILED: Authentication attempt from 203.0.113.100
2025-01-15 09:17:33 ERROR: Invalid certificate detected
2025-01-15 09:18:12 Password changed for user john
2025-01-15 09:19:55 CRITICAL: Brute force attack from 198.51.100.25
2025-01-15 09:20:41 Security scan completed
2025-01-15 09:21:18 FAILED: Access denied to restricted resource
2025-01-15 09:22:07 User logout: admin from 192.168.1.50
EOF

fi

# Display detailed file listing
ls -lh out/monitor/raw/

# Count total lines
echo ""
echo "Total lines across all logs:"
wc -l out/monitor/raw/*.log | tail -1
