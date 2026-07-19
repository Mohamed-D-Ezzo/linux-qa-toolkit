#!/bin/bash
# git-workflow.sh — automate daily Git push for linux-qa-toolkit
# Usage: ./git-workflow.sh "Day 12: add git script" scripts/git-workflow.sh

MSG="${1:-chore: update scripts}"
FILES="${@:2}"
REPO=~/linux-qa-toolkit

if [ ! -d "$REPO/.git" ]; then
  echo "[FAIL] Not a git repo: $REPO"; exit 1
fi

cd "$REPO"

# Pull latest first
echo "[INFO] Pulling latest from main..."
git pull origin main --rebase

# Stage files (all if none specified)
if [ -z "$FILES" ]; then
  git add .
else
  git add $FILES
fi

# Check if anything to commit
if git diff --cached --quiet; then
  echo "[INFO] Nothing to commit."; exit 0
fi

git commit -m "$MSG"
git push origin main
echo "[OK] Pushed: $MSG"