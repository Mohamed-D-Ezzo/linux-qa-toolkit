#!/bin/bash
# test-runner.sh — simulates running multiple test suites

PASS=0; FAIL=0; SKIP=0
LOG=~/qa-practice/logs/test-run-$(date +%Y%m%d-%H%M%S).log

# --- Functions ---
log() { echo "$1" | tee -a "$LOG"; }

run_test() {
  local name="$1"
  local should_pass="$2"   # pass or fail

  log "  Running: $name..."
  sleep 0.3                   # simulate test execution time

  if [ "$should_pass" = "pass" ]; then
    log "  PASS: $name"
    PASS=$((PASS + 1))
  else
    log "  FAIL: $name"
    FAIL=$((FAIL + 1))
  fi
}

run_suite() {
  local suite_name="$1"
  shift                        # remove first arg, rest are tests
  log ""
  log "=== Suite: $suite_name ==="
  for test in "$@"; do
    IFS=":" read -r tname result <<< "$test"
    run_test "$tname" "$result"
  done
}

# --- Test suites ---
log "QA Test Runner — $(date)"

run_suite "Login Tests" \
  "Valid login:pass" \
  "Invalid password:pass" \
  "Empty username:fail"

run_suite "API Tests" \
  "GET /users returns 200:pass" \
  "POST /users creates record:pass" \
  "DELETE without auth returns 401:fail"

run_suite "UI Tests" \
  "Homepage loads:pass" \
  "Navigation works:pass" \
  "Form submission:pass"

# --- Summary ---
TOTAL=$((PASS + FAIL))
log ""
log "=== Results ==="
log "Total : $TOTAL"
log "Pass  : $PASS"
log "Fail  : $FAIL"
log "Log   : $LOG"

[ $FAIL -eq 0 ] && { log "All tests passed!"; exit 0; } \
               || { log "$FAIL test(s) failed."; exit 1; }