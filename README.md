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
qa-practice/
├── scripts/        # Bash scripts
├── logs/           # Application logs
├── reports/        # Generated check reports
└── .env            # Environment config (not committed)

## Skills Demonstrated
- Bash scripting: functions, loops, conditionals
- File permissions and environment variables
- System monitoring with free and df
- Log analysis with grep and find
- Git version control

## Author
Mohamed Ezzo — QA Engineer | DevOps for QA Journey
