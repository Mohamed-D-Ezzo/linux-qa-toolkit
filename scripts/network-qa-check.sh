#!/bin/bash
# network-qa-check.sh — verify network readiness before test run
# Usage: ./network-qa-check.sh https://yourapp.com 3000

BASE_URL="${1:-http://localhost:3000}"
PORT="${2:-3000}"
HOST=$(echo "$BASE_URL" | sed 's|https\?://||;s|/.*||')
REPORT=~/qa-practice/reports/network-check-$(date +%Y%m%d-%H%M).txt
mkdir -p ~/qa-practice/reports

PASS=0; FAIL=0

log_ok()   { echo "[OK]   $1" | tee -a "$REPORT"; ((PASS++)); }
log_fail() { echo "[FAIL] $1" | tee -a "$REPORT"; ((FAIL++)); }
log_warn() { echo "[WARN] $1" | tee -a "$REPORT"; }

echo "=== Network QA Check === $(date)" | tee "$REPORT"
echo "Target: $BASE_URL"               | tee -a "$REPORT"
echo "---"                             | tee -a "$REPORT"

# 1. DNS resolution
if dig +short "$HOST" &>/dev/null; then
  log_ok "DNS resolves: $HOST → $(dig +short $HOST | head -1)"
else
  log_fail "DNS failed for $HOST"
fi

# 2. Port check
if nc -zw3 "$HOST" "$PORT" 2>/dev/null; then
  log_ok "Port $PORT is open on $HOST"
else
  log_fail "Port $PORT is CLOSED on $HOST"
fi

# 3. HTTP status check
STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$BASE_URL" 2>/dev/null)
if [[ "$STATUS" =~ ^2 ]]; then
  log_ok "HTTP status: $STATUS"
elif [[ "$STATUS" =~ ^3 ]]; then
  log_warn "HTTP redirect: $STATUS"
else
  log_fail "HTTP status: $STATUS"
fi

# 4. Response time check
TIME=$(curl -s -o /dev/null -w "%{time_total}" --max-time 10 "$BASE_URL")
TIME_MS=$(echo "$TIME * 1000" | bc | cut -d. -f1)
if [ "$TIME_MS" -lt 2000 ]; then
  log_ok "Response time: ${TIME_MS}ms"
else
  log_warn "Slow response: ${TIME_MS}ms (>2s)"
fi

# 5. Internet access check
if ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
  log_ok "Internet access: OK"
else
  log_fail "No internet access"
fi

# Summary
echo "---"                                           | tee -a "$REPORT"
echo "Result: $PASS passed, $FAIL failed"            | tee -a "$REPORT"
echo "Report: $REPORT"                               | tee -a "$REPORT"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0