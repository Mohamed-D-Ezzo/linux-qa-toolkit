#!/bin/bash
# env-selector.sh — interactive QA environment selector

# Default values
VALID_ENVS=("dev" "staging" "prod")

# Show menu
echo "========================="
echo "  QA Environment Selector"
echo "========================="
echo "1) dev      — http://localhost:3000"
echo "2) staging  — https://staging.myapp.com"
echo "3) prod     — https://myapp.com"
echo

# Get input
read -p "Select environment [dev/staging/prod]: " ENV

# Validate — check if empty
if [ -z "$ENV" ]; then
  echo "ERROR: No environment selected."
  exit 1
fi

# Set URL based on selection
if [ "$ENV" = "dev" ]; then
  BASE_URL="http://localhost:3000"
  TIMEOUT=5
elif [ "$ENV" = "staging" ]; then
  BASE_URL="https://staging.myapp.com"
  TIMEOUT=15
elif [ "$ENV" = "prod" ]; then
  read -p "WARNING: prod selected. Are you sure? [yes/no]: " CONFIRM
  if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted."
    exit 0
  fi
  BASE_URL="https://myapp.com"
  TIMEOUT=30
else
  echo "ERROR: Invalid environment '$ENV'"
  echo "Valid options: dev, staging, prod"
  exit 1
fi

# Export for child processes
export BASE_URL
export ENVIRONMENT=$ENV

# Confirm and show summary
echo
echo "--- Environment Ready ---"
echo "Environment : $ENV"
echo "Base URL    : $BASE_URL"
echo "Timeout     : ${TIMEOUT}s"
echo "Ready to run tests!"
exit 0