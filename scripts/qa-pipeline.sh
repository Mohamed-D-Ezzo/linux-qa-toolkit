#!/bin/bash
# qa-pipeline.sh — Week 2 capstone: full QA automation pipeline
# Combines: variables, loops, functions, pipes, SSH, Git, networking
# Usage: ./qa-pipeline.sh
# Exit:  0 = all checks passed | 1 = one or more failed

set -uo pipefail

# ── Config ────────────────────────────────────────────
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
LOG_DIR="$REPO_ROOT/reports"
LOG="$LOG_DIR/qa-run-$(date +%Y%m%d-%H%M%S).txt"
PASS=0; FAIL=0; WARN=0

mkdir -p "$LOG_DIR"

# ── Colors ────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

# ── Logging functions (Day 9: functions) ─────────────
log_ok()   { echo -e "${GREEN}[OK]${NC}   $1" | tee -a "$LOG"; ((PASS++)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $1" | tee -a "$LOG"; ((FAIL++)); }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG"; ((WARN++)); }
log_info() { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG"; }
section()  { echo -e "\n── $1 ──────────────────────────" | tee -a "$LOG"; }

# ── Header ────────────────────────────────────────────
echo "============================================" | tee "$LOG"
echo " QA Pipeline — $(date)"                     | tee -a "$LOG"
echo " Repo: $REPO_ROOT"                          | tee -a "$LOG"
echo "============================================" | tee -a "$LOG"

# ── 1. Environment checks (Day 8: variables/conditionals) ──
section "1. Environment"

REQUIRED_TOOLS=(curl wget git nc node npm)
for tool in "${REQUIRED_TOOLS[@]}"; do   # Day 9: loops
  if command -v "$tool" &>/dev/null; then
    log_ok "$tool installed: $($tool --version 2>&1 | head -1)"
  else
    log_fail "$tool not found — install it first"
  fi
done

# Check .env file exists
if [ -f "$REPO_ROOT/.env" ]; then
  log_ok ".env file found"
else
  log_warn ".env not found — using defaults"
fi

# ── 2. Network checks (Day 13: curl, ports) ──────────
section "2. Network"

# Function to check a URL (Day 9: functions)
check_url() {
  local url="$1"
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null)
  if [[ "$status" =~ ^2 ]]; then
    log_ok "$url → HTTP $status"
  elif [[ "$status" =~ ^3 ]]; then
    log_warn "$url → HTTP $status (redirect)"
  else
    log_fail "$url → HTTP $status"
  fi
}

URLS=(                                         # Day 9: arrays
  "https://jsonplaceholder.typicode.com/posts/1"
  "https://jsonplaceholder.typicode.com/users"
  "https://github.com"
)
for url in "${URLS[@]}"; do
  check_url "$url"
done

# Port check
check_port() {
  if nc -zw3 "$1" "$2" 2>/dev/null; then
    log_ok "Port $2 open on $1"
  else
    log_warn "Port $2 closed on $1"
  fi
}
check_port github.com 443
check_port localhost 22

# ── 3. Git status check (Day 12: git) ───────────────
section "3. Git"

cd "$REPO_ROOT"
if git rev-parse --is-inside-work-tree &>/dev/null; then
  BRANCH=$(git branch --show-current)
  LAST_COMMIT=$(git log --oneline -1)
  DIRTY=$(git status --porcelain | wc -l)     # Day 10: pipes
  log_ok "Branch: $BRANCH"
  log_ok "Last commit: $LAST_COMMIT"
  [ "$DIRTY" -gt 0 ] \
    && log_warn "$DIRTY uncommitted changes" \
    || log_ok  "Working tree clean"
else
  log_fail "Not inside a git repo"
fi

# ── 4. Run a smoke test (Day 9: loops + Day 10: pipes) ──
section "4. Smoke Tests"

smoke_test() {
  local name="$1" url="$2" expect="$3"
  local body
  body=$(curl -sf --max-time 5 "$url" 2>/dev/null)
  if echo "$body" | grep -q "$expect"; then  # Day 10: grep in pipe
    log_ok "$name: response contains '$expect'"
  else
    log_fail "$name: '$expect' not found in response"
  fi
}

smoke_test "Get post"    "https://jsonplaceholder.typicode.com/posts/1"  "userId"
smoke_test "Get users"   "https://jsonplaceholder.typicode.com/users"    "email"
smoke_test "Get todos"   "https://jsonplaceholder.typicode.com/todos/1"  "completed"

# ── 5. Generate report + auto-commit (Day 12: git) ───
section "5. Report"

echo ""                                              | tee -a "$LOG"
echo "============================================"  | tee -a "$LOG"
echo " PASSED : $PASS"                               | tee -a "$LOG"
echo " FAILED : $FAIL"                               | tee -a "$LOG"
echo " WARNED : $WARN"                               | tee -a "$LOG"
echo " Report : $LOG"                                | tee -a "$LOG"
echo "============================================"  | tee -a "$LOG"

# Auto-commit report to Git
cd "$REPO_ROOT"
git add reports/
git diff --cached --quiet || \
  git commit -m "report: qa-pipeline run $(date +%Y%m%d-%H%M)" && \
  git push origin main 2>/dev/null && \
  log_info "Report pushed to GitHub"

# ── 6. Exit with CI-friendly code ────────────────────
[ "$FAIL" -gt 0 ] && exit 1 || exit 0