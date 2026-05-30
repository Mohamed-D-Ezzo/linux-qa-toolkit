#!/bin/bash

REPORT_DIR=~/qa-practice/reports
LOG_DIR=~/qa-practice/logs
REPORT="$REPORT_DIR/qa-check-$(date +%Y%m%d-%H%M%S).txt"
PASS=0
FAIL=0
WARN=0

mkdir -p "$REPORT_DIR" "$LOG_DIR"

log() {
  echo "$1" | tee -a "$REPORT"
}

pass() {
  echo "  PASS: $1" | tee -a "$REPORT"
  PASS=$((PASS + 1))
}

fail() {
  echo "  FAIL: $1" | tee -a "$REPORT"
  FAIL=$((FAIL + 1))
}

warn() {
  echo "  WARN: $1" | tee -a "$REPORT"
  WARN=$((WARN + 1))
}

section() {
  log ""
  log "=== $1 ==="
}

log "QA Environment Check Report"
log "Date : $(date)"
log "User : $(whoami)"
log "Host : $(hostname)"

section "Required Tools"
TOOLS=("bash" "git" "curl" "nano" "grep" "find")
for tool in "${TOOLS[@]}"; do
  if command -v "$tool" &>/dev/null; then
    pass "$tool found"
  else
    fail "$tool NOT FOUND"
  fi
done

section "Project Structure"
DIRS=(
  "$HOME/qa-practice"
  "$HOME/qa-practice/scripts"
  "$HOME/qa-practice/logs"
  "$HOME/qa-practice/reports"
)
for dir in "${DIRS[@]}"; do
  if [ -d "$dir" ]; then
    pass "$dir exists"
  else
    fail "$dir missing"
  fi
done

section "System Resources"
MEM_FREE=$(free -m | grep Mem | awk '{print $7}')
DISK_PCT=$(df -h / | tail -1 | awk '{print $5}' | tr -d '%')

if [ "$MEM_FREE" -gt 512 ]; then
  pass "Free memory: ${MEM_FREE}MB"
else
  warn "Low memory: ${MEM_FREE}MB"
fi

if [ "$DISK_PCT" -lt 90 ]; then
  pass "Disk usage: ${DISK_PCT}%"
else
  fail "Disk almost full: ${DISK_PCT}%"
fi

section "Environment Variables"
for var in HOME USER PATH SHELL; do
  if [ -n "${!var}" ]; then
    pass "$var is set"
  else
    fail "$var is NOT set"
  fi
done

section "Summary"
log "  Passed   : $PASS"
log "  Warnings : $WARN"
log "  Failed   : $FAIL"
log ""
log "Report saved to: $REPORT"

if [ "$FAIL" -eq 0 ]; then
  log "Environment is ready!"
  exit 0
else
  log "Fix $FAIL issue(s) before running tests."
  exit 1
fi