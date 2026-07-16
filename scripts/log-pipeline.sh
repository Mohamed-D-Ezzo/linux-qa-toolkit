#!/bin/bash
# log-pipeline.sh — full log analysis using pipes and redirection

LOG=~/qa-practice/logs/app.log
REPORT=~/qa-practice/reports/analysis-$(date +%Y%m%d).txt

# Create sample log if it doesn't exist
if [ ! -f "$LOG" ]; then
  mkdir -p ~/qa-practice/logs
  cat > "$LOG" << 'EOF'
[2026-05-01 10:01] INFO  Server started on port 3000
[2026-05-01 10:02] ERROR Login failed for user: admin
[2026-05-01 10:03] INFO  GET /api/users 200 OK 145ms
[2026-05-01 10:04] WARN  Response slow: 1200ms
[2026-05-01 10:05] ERROR Database timeout after 5000ms
[2026-05-01 10:06] ERROR Login failed for user: testuser
[2026-05-01 10:07] INFO  GET /api/products 200 OK 89ms
[2026-05-01 10:08] ERROR Database timeout after 5000ms
[2026-05-01 10:09] WARN  Memory usage at 82%
[2026-05-01 10:10] ERROR Login failed for user: admin
EOF
fi

echo "=== Log Analysis Report ===" | tee "$REPORT"
echo "Date: $(date)"              | tee -a "$REPORT"
echo "File: $LOG"                 | tee -a "$REPORT"
echo ""                           | tee -a "$REPORT"

# Count by level
echo "--- Line counts ---"        | tee -a "$REPORT"
echo "Total lines : $(wc -l < $LOG)"               | tee -a "$REPORT"
echo "Errors      : $(grep -c "ERROR" $LOG)"       | tee -a "$REPORT"
echo "Warnings    : $(grep -c "WARN"  $LOG)"       | tee -a "$REPORT"
echo "Info        : $(grep -c "INFO"  $LOG)"       | tee -a "$REPORT"

# Most frequent errors
echo ""                                             | tee -a "$REPORT"
echo "--- Top errors ---"                           | tee -a "$REPORT"
cat "$LOG" | grep "ERROR" | sort | uniq -c | sort -rn | tee -a "$REPORT"

# Slow responses
echo ""                                             | tee -a "$REPORT"
echo "--- Warnings ---"                             | tee -a "$REPORT"
cat "$LOG" | grep "WARN" | tee -a "$REPORT"

echo ""
echo "Report saved: $REPORT"