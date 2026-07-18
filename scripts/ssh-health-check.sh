#!/bin/bash
# ssh-health-check.sh — Remote server health check via SSH
# Usage: ./ssh-health-check.sh <ssh-host>
# Example: ./ssh-health-check.sh local-qa

set -euo pipefail

# ─── Config ──────────────────────────────────────────
TARGET="${1:-local-qa}"
REPORT=~/qa-practice/reports/ssh-health-$(date +%Y%m%d-%H%M%S).txt
mkdir -p ~/qa-practice/reports

# ─── Colors ──────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()    { echo -e "${BLUE}[INFO]${NC}  $1" | tee -a "$REPORT"; }
ok()     { echo -e "${GREEN}[OK]${NC}    $1" | tee -a "$REPORT"; }
warn()   { echo -e "${YELLOW}[WARN]${NC}  $1" | tee -a "$REPORT"; }
fail()   { echo -e "${RED}[FAIL]${NC}  $1" | tee -a "$REPORT"; }

# ─── Check SSH Connectivity ───────────────────────────
echo "============================================" | tee "$REPORT"
echo " SSH Health Check — $(date)"                 | tee -a "$REPORT"
echo " Target: $TARGET"                             | tee -a "$REPORT"
echo "============================================" | tee -a "$REPORT"
echo ""

log "Testing SSH connection to [$TARGET]..."
if ssh -o ConnectTimeout=5 -o BatchMode=yes "$TARGET" exit 2>/dev/null; then
    ok "SSH connection successful"
else
    fail "Cannot connect to $TARGET — check your SSH config"
    exit 1
fi

# ─── Collect Remote Info ──────────────────────────────
log "Collecting remote server info..."

HOSTNAME=$(ssh "$TARGET" "hostname")
UPTIME=$(ssh "$TARGET" "uptime -p")
OS=$(ssh "$TARGET" "lsb_release -d 2>/dev/null | cut -f2 || uname -s")
KERNEL=$(ssh "$TARGET" "uname -r")
CPU_USAGE=$(ssh "$TARGET" "top -bn1 | grep 'Cpu(s)' | awk '{print \$2}' | cut -d'%' -f1")
MEM_TOTAL=$(ssh "$TARGET" "free -h | grep Mem | awk '{print \$2}'")
MEM_USED=$(ssh "$TARGET"  "free -h | grep Mem | awk '{print \$3}'")
MEM_PCT=$(ssh "$TARGET"   "free | grep Mem | awk '{printf \"%.0f\", \$3/\$2*100}'")
DISK_PCT=$(ssh "$TARGET"  "df -h / | tail -1 | awk '{print \$5}' | tr -d '%'")
DISK_FREE=$(ssh "$TARGET" "df -h / | tail -1 | awk '{print \$4}'")

# ─── Display Results ──────────────────────────────────
echo "" | tee -a "$REPORT"
echo "─── Server Info ───────────────────────────" | tee -a "$REPORT"
log "Hostname : $HOSTNAME"
log "OS       : $OS"
log "Kernel   : $KERNEL"
log "Uptime   : $UPTIME"

echo "" | tee -a "$REPORT"
echo "─── Resource Usage ────────────────────────" | tee -a "$REPORT"

# CPU check
if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
    warn "CPU Usage: ${CPU_USAGE}% — HIGH"
else
    ok "CPU Usage: ${CPU_USAGE}%"
fi

# Memory check
if [ "$MEM_PCT" -gt 85 ]; then
    warn "Memory: ${MEM_USED}/${MEM_TOTAL} (${MEM_PCT}%) — HIGH"
else
    ok "Memory: ${MEM_USED}/${MEM_TOTAL} (${MEM_PCT}%)"
fi

# Disk check
if [ "$DISK_PCT" -gt 85 ]; then
    warn "Disk: ${DISK_PCT}% used — ${DISK_FREE} free — LOW SPACE"
else
    ok "Disk: ${DISK_PCT}% used — ${DISK_FREE} free"
fi

# ─── Check QA Tools on Remote ─────────────────────────
echo "" | tee -a "$REPORT"
echo "─── QA Tools Available ────────────────────" | tee -a "$REPORT"

tools=("node" "npm" "python3" "git" "docker" "curl")
for tool in "${tools[@]}"; do
    version=$(ssh "$TARGET" "command -v $tool &>/dev/null && $tool --version 2>&1 | head -1 || echo 'NOT FOUND'")
    if [[ "$version" == "NOT FOUND" ]]; then
        warn "$tool: not installed"
    else
        ok "$tool: $version"
    fi
done

# ─── Network Connectivity from Remote ─────────────────
echo "" | tee -a "$REPORT"
echo "─── Remote Network Check ──────────────────" | tee -a "$REPORT"

if ssh "$TARGET" "ping -c 1 google.com &>/dev/null"; then
    ok "Internet connectivity: OK"
else
    warn "Internet connectivity: FAILED"
fi

if ssh "$TARGET" "ping -c 1 github.com &>/dev/null"; then
    ok "GitHub reachable: OK"
else
    warn "GitHub reachable: FAILED"
fi

# ─── Summary ──────────────────────────────────────────
echo "" | tee -a "$REPORT"
echo "============================================" | tee -a "$REPORT"
echo " Report saved: $REPORT"
echo "============================================" | tee -a "$REPORT"