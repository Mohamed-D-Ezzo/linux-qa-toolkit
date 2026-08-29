#!/bin/bash
# docker-first-run.sh — Day 16: prove the Docker daemon works
# Same purpose as qa-checker.sh proved bash/curl existed — this proves
# Docker is installed, the daemon is reachable, and containers can run,
# be published on a port, and be cleaned up.
#
# Usage: ./docker-first-run.sh

set -uo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_ok()   { echo -e "${GREEN}[OK]${NC}   $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }

PASS=0
FAIL=0

echo "============================================"
echo " Docker First-Run Check — $(date)"
echo "============================================"

# ── 1. Daemon reachable ────────────────────────────────
log_info "Checking Docker client + daemon (docker version)..."
if docker version >/dev/null 2>&1; then
  log_ok "Docker Client and Server both reachable"
  ((PASS++))
else
  log_fail "Docker daemon not reachable — is Docker Desktop running?"
  ((FAIL++))
  echo "Aborting — nothing else will work without the daemon."
  exit 1
fi

# ── 2. hello-world proves the pull+run+exit cycle ──────
log_info "Running hello-world (--rm, auto-cleans itself)..."
if docker run --rm hello-world >/tmp/docker-hello-output.txt 2>&1; then
  log_ok "hello-world ran and exited cleanly (exit 0)"
  ((PASS++))
else
  log_fail "hello-world failed to run — check /tmp/docker-hello-output.txt"
  ((FAIL++))
fi

# ── 3. Start a real long-running container ─────────────
log_info "Starting qa-nginx on port 8088..."
docker rm -f qa-nginx >/dev/null 2>&1  # clean up any leftover from a previous run
if docker run -d --name qa-nginx -p 8088:80 nginx:alpine >/dev/null 2>&1; then
  log_ok "qa-nginx container started"
  ((PASS++))
else
  log_fail "Could not start qa-nginx (port 8088 busy?)"
  ((FAIL++))
fi

# Give nginx a moment to be ready
sleep 1

# ── 4. Verify it's actually serving traffic ────────────
log_info "Curling http://127.0.0.1:8088 ..."
STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://127.0.0.1:8088)
if [ "$STATUS" = "200" ]; then
  log_ok "nginx responded with HTTP $STATUS"
  ((PASS++))
else
  log_fail "nginx did not respond as expected (got: $STATUS)"
  ((FAIL++))
fi

# ── 5. Confirm it shows up in docker ps ────────────────
log_info "Checking docker ps for qa-nginx..."
if docker ps --format '{{.Names}}' | grep -q '^qa-nginx$'; then
  log_ok "qa-nginx listed as running"
  ((PASS++))
else
  log_fail "qa-nginx not found in docker ps"
  ((FAIL++))
fi

# ── 6. Clean up ─────────────────────────────────────────
log_info "Stopping and removing qa-nginx..."
docker stop qa-nginx >/dev/null 2>&1
docker rm qa-nginx >/dev/null 2>&1
log_ok "qa-nginx stopped and removed"

# ── Summary ──────────────────────────────────────────
echo "============================================"
echo " Result: $PASS passed, $FAIL failed"
echo "============================================"

[ "$FAIL" -gt 0 ] && exit 1 || exit 0