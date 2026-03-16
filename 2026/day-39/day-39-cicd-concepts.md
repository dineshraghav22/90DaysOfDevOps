# Day 39 – What is CI/CD?

## Task 1: The Problem

**5 developers pushing code manually to production:**

What can go wrong:
1. **Broken code reaches production** — no automated tests, one developer's mistake breaks the app for all users
2. **"It works on my machine"** — Developer A tested on Python 3.11, production runs 3.9. Library versions differ. Works locally, fails in prod.
3. **Merge conflicts multiply** — 5 developers working on the same codebase without frequent integration → diverging branches → painful merges
4. **No rollback plan** — manual deployments with no artifact versioning make it hard to roll back to a known good state
5. **Fear of deploying** — if deployments are risky and manual, teams do them less often → more changes per deploy → more risk per deploy → even more fear

**How often can a team safely deploy manually?**
Realistically, 1-2 times per week for small teams (manual process takes hours, needs coordination). With CI/CD: multiple times per day with confidence.

---

## Task 2: CI vs CD

### Continuous Integration (CI)
Every developer merges code to the shared main branch frequently (multiple times daily). On each merge, automated tests run to verify the integration doesn't break anything.

**What happens:** Developer pushes code → pipeline triggers → lint → unit tests → integration tests → build → report pass/fail

**What it catches:** Broken code, test failures, merge conflicts, code style violations, missing dependencies

**Real-world example:** A developer adds a new endpoint to the API. CI runs 200 unit tests and finds that 3 tests fail because the new endpoint conflicts with existing authentication logic. The developer fixes it before it reaches main.

---

### Continuous Delivery (CD — Delivery)
Every passing CI build produces a deployable artifact. The artifact CAN be deployed to production with a single button press (human approval still required).

**Difference from CI:** CI validates the code. Delivery ensures it's packaged and ready to deploy at any moment.

**Real-world example:** After CI passes, a Docker image is built, tagged with the commit hash, and pushed to the registry. A staging environment is automatically updated. A human clicks "Deploy to production" when ready.

---

### Continuous Deployment (CD — Deployment)
Every passing CI build IS automatically deployed to production — no human approval.

**Difference from Delivery:** Deployment removes the human gate entirely. If tests pass, it goes to production.

**When teams use it:** High-confidence test suites, feature flags to control rollout, strong observability (metrics, logs, alerts). Used by companies like Netflix, GitHub, Etsy — deploying dozens of times per day.

**Real-world example:** Developer merges a PR → tests pass → Docker image builds → pushed to registry → Kubernetes deployment updated automatically → monitoring confirms no error spike.

---

## Task 3: Pipeline Anatomy

| Term | Definition |
|------|-----------|
| **Trigger** | The event that starts the pipeline. Common triggers: `git push`, `pull request opened`, `schedule (cron)`, `manual dispatch` |
| **Stage** | A logical phase of the pipeline. Common stages: `lint`, `test`, `build`, `security-scan`, `deploy-staging`, `deploy-production` |
| **Job** | A unit of work within a stage. Each job runs independently (possibly in parallel). Example: `unit-tests` job and `integration-tests` job both in the `test` stage |
| **Step** | A single command or action within a job. Example: `pip install -r requirements.txt`, `pytest tests/` |
| **Runner** | The machine (or container) that executes the job. GitHub Actions: `ubuntu-latest`. Jenkins: a configured Jenkins agent. Self-hosted: your own server |
| **Artifact** | Output produced by a job, passed to subsequent stages. Examples: compiled binary, Docker image, test report, coverage HTML |

---

## Task 4: Pipeline Diagram

**Scenario:** Developer pushes → app tested → Docker image built → deployed to staging

```
TRIGGER: Developer pushes code to GitHub
         ↓
┌─────────────────────────────────────────────────────┐
│  STAGE 1: Validate                                   │
│  Job: lint                                           │
│    Step 1: git checkout                              │
│    Step 2: pip install flake8                        │
│    Step 3: flake8 app/                               │
│  Job: unit-tests                                     │
│    Step 1: git checkout                              │
│    Step 2: pip install -r requirements.txt           │
│    Step 3: pytest tests/unit/                        │
└────────────────────────┬────────────────────────────┘
                         ↓ (both jobs must pass)
┌─────────────────────────────────────────────────────┐
│  STAGE 2: Build                                      │
│  Job: docker-build                                   │
│    Step 1: git checkout                              │
│    Step 2: docker build -t myapp:$COMMIT_SHA .       │
│    Step 3: docker push registry/myapp:$COMMIT_SHA    │
│  Artifact: Docker image tagged with commit SHA       │
└────────────────────────┬────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│  STAGE 3: Deploy to Staging                          │
│  Job: deploy-staging                                 │
│    Step 1: Pull image from registry                  │
│    Step 2: docker compose up --build on staging      │
│    Step 3: Run smoke tests                           │
│    Step 4: Notify Slack "#deployments"               │
└─────────────────────────────────────────────────────┘
```

---

## Task 5: Explore in the Wild – FastAPI

**Repo:** `tiangolo/fastapi`
**Location:** `.github/workflows/test.yml`

```yaml
# Trigger
on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.8", "3.9", "3.10", "3.11", "3.12"]
```

**Findings:**
- **Trigger:** Every push to master AND every pull request to master
- **Jobs:** ~3 jobs (lint, test with matrix, coverage)
- **Matrix strategy:** Tests run on 5 Python versions in parallel
- **What it does:** Installs dependencies, runs pytest, uploads coverage to codecov

**Key insight:** The matrix strategy means 5 parallel test runs → catches Python version compatibility issues automatically.

---

## What I Learned

1. **CI/CD is a practice, not a tool** — GitHub Actions, Jenkins, GitLab CI are all tools that implement CI/CD. The goal is always the same: fast feedback on code changes, reliable automated delivery.
2. **The cost of CI is small compared to the cost of not having it** — a CI pipeline takes hours to set up. One production incident from untested code can cost days to fix and thousands in lost revenue.
3. **Trunk-Based Development and CI are symbiotic** — CI works best when everyone integrates frequently. Long-lived branches accumulate changes and make CI less effective.
