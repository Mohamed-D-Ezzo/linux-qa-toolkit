# Linux QA Toolkit

Bash scripts for QA engineers on Linux and WSL2.
Built as part of a DevOps for QA learning roadmap.

## Scripts

### qa-checker.sh

Checks your QA environment is ready before running tests.

Verifies:

- Required tools installed (bash, git, curl, nano, grep, find)
- Project folder structure exists
- System resources (memory and disk space)
- Environment variables are set correctly

Usage:

```bash
chmod +x scripts/qa-checker.sh
./scripts/qa-checker.sh
```

Output: timestamped report saved to /reports/

## Project Structure
