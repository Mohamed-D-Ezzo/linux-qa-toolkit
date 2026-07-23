# 🐼 linux-qa-toolkit

A 14-day Linux learning journey built specifically for QA Automation Engineers.
Every script was written from scratch — no copy-paste, all real QA use cases.

Built by [Mohamed Ezzo](https://github.com/Mohamed-D-Ezzo) — QA Automation Engineer

---

## 📁 Scripts

| Script | Day | What it does |
|---|---|---|
| `env-selector.sh` | Day 8 | Select and switch between QA environments (dev / staging / prod) |
| `log-pipeline.sh` | Day 10 | Full log analysis using pipes and redirection |
| `test-runner.sh` | Day 10 | Run test suites and capture structured output |
| `ssh-health-check.sh` | Day 11 | SSH into a server and collect health stats before test run |
| `git-workflow.sh` | Day 12 | Automate daily Git add → commit → push for this repo |
| `network-qa-check.sh` | Day 13 | Pre-test network readiness check (DNS, ports, HTTP status, response time) |
| `qa-checker.sh` | Day 13 | Targeted QA environment checker with pass/fail reporting |
| `qa-pipeline.sh` | Day 14 | Full CI-ready pipeline combining all skills — environment, network, git, smoke tests |

---

## 🚀 Quick Start

```bash
# Clone the repo
git clone https://github.com/Mohamed-D-Ezzo/linux-qa-toolkit.git
cd linux-qa-toolkit

# Make all scripts executable
chmod +x scripts/*.sh

# Run the full QA pipeline
./scripts/qa-pipeline.sh

# Run network check against a target
./scripts/network-qa-check.sh https://yourapp.com 443

# SSH health check (requires SSH config alias)
./scripts/ssh-health-check.sh qa-server
```

---

## 🗺️ 14-Day Journey

### Week 1 — Linux Foundations

| Day | Topic |
|---|---|
| Day 1 | Filesystem navigation — pwd, ls, cd, find |
| Day 2 | File operations — cp, mv, rm, mkdir, touch |
| Day 3 | Viewing & editing files — cat, less, nano, head, tail |
| Day 4 | Permissions — chmod, chown, umask |
| Day 5 | Users & groups — whoami, sudo, adduser |
| Day 6 | Processes — ps, top, kill, htop |
| Day 7 | Week 1 project — environment audit script |

### Week 2 — Scripting & Automation

| Day | Topic |
|---|---|
| Day 8 | Variables, conditionals, exit codes |
| Day 9 | Loops & functions |
| Day 10 | Pipes, redirection & text processing |
| Day 11 | SSH — connecting to remote servers |
| Day 12 | Git inside Linux — the real workflow |
| Day 13 | Networking basics — curl, wget, ports |
| Day 14 | Week 2 project — full QA automation pipeline |

---

## 📊 Reports

Each script saves a timestamped report to `reports/` automatically.

```
reports/
├── qa-run-20260723-072301.txt
├── network-check-20260723-0715.txt
└── ssh-health-20260723.txt
```

Reports are auto-committed to this repo after each pipeline run.

---

## 🛠️ Requirements

- Ubuntu 20.04+ / WSL2 with Ubuntu 24.04
- bash 5+
- curl, wget, git, nc, node, npm (checked automatically by `qa-pipeline.sh`)

---

## 📌 What's Next — Week 3

- Docker for QA environments
- CI/CD with GitHub Actions
- Running Playwright inside Docker
- Automated test reporting pipelines

---

*Part of the DevOps for QA 8-week roadmap — QA Panda 🐼*
