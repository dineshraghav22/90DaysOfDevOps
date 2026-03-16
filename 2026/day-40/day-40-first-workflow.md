# Day 40 – Your First GitHub Actions Workflow

## Setup

1. Created repo `github-actions-practice` on GitHub (public)
2. Cloned locally
3. Created `.github/workflows/` directory structure
4. Created `hello.yml` workflow file

---

## The Workflow File

```yaml
name: Hello GitHub Actions

on:
  push:
    branches: ["**"]        # triggers on push to ANY branch
  pull_request:
    branches: [main]        # triggers on PRs targeting main

jobs:
  greet:
    runs-on: ubuntu-latest  # use GitHub's Ubuntu runner

    steps:
      - name: Checkout code
        uses: actions/checkout@v4          # downloads repo to runner

      - name: Say Hello
        run: echo "Hello from GitHub Actions!"

      - name: Print current date and time
        run: date

      - name: Print branch name
        run: echo "Branch that triggered: ${{ github.ref_name }}"

      - name: List files in repo
        run: ls -la

      - name: Print runner OS
        run: echo "Runner OS: ${{ runner.os }}"
```

---

## Task 3: Workflow Anatomy

| Key | What it does |
|-----|-------------|
| `on:` | Defines what events trigger the workflow. `push`, `pull_request`, `schedule`, `workflow_dispatch` are common |
| `jobs:` | Container for all jobs in the workflow. Each key is a job ID |
| `runs-on:` | Specifies the runner machine. `ubuntu-latest`, `windows-latest`, `macos-latest`, or self-hosted |
| `steps:` | Ordered list of tasks within a job. Each step runs sequentially |
| `uses:` | References a reusable Action from the marketplace. `actions/checkout@v4` checks out your code |
| `run:` | Executes a shell command directly. Uses bash on Linux/Mac, PowerShell on Windows |
| `name:` (on a step) | Human-readable label shown in the GitHub Actions UI |

---

## Task 4: Steps Added

**Print current date:**
```yaml
- name: Print current date and time
  run: date
```
Output: `Thu Mar  5 06:00:00 UTC 2026`

**Print branch name (GitHub context variable):**
```yaml
- name: Print branch name
  run: echo "Branch that triggered: ${{ github.ref_name }}"
```
Output: `Branch that triggered: main`

**List files:**
```yaml
- name: List files in repo
  run: ls -la
```
Output: shows all files in the repo root

**Print runner OS:**
```yaml
- name: Print runner OS
  run: echo "Runner OS: ${{ runner.os }}"
```
Output: `Runner OS: Linux`

---

## Task 5: Breaking It On Purpose

**Added a failing step:**
```yaml
- name: This will FAIL
  run: exit 1
```

**What happened in Actions tab:**
- The failing step shows a red X
- All subsequent steps in that job are skipped
- The job status shows "Failure"
- GitHub sends an email notification (if enabled)
- The pipeline stops — deploy steps don't run

**How to read the error:**
1. Click on the failed job in the Actions tab
2. Click on the red X step
3. Read the log — `exit 1` shows exit code 1 (error)

**Fixed it:**
Removed the `exit 1` step, pipeline went green again.

---

## GitHub Context Variables Used

| Variable | Value |
|----------|-------|
| `${{ github.ref_name }}` | Branch name: `main` |
| `${{ github.sha }}` | Commit SHA: `abc1234...` |
| `${{ github.actor }}` | User who triggered: your username |
| `${{ github.repository }}` | `owner/repo-name` |
| `${{ runner.os }}` | `Linux` |
| `${{ github.event_name }}` | `push` or `pull_request` |

---

## Pipeline Run Results

**Green run output:**
```
✓ Checkout code          (1s)
✓ Say Hello              (0s) → "Hello from GitHub Actions!"
✓ Print current date     (0s) → "Thu Mar  5 06:00:00 UTC 2026"
✓ Print branch name      (0s) → "Branch that triggered: main"
✓ List files in repo     (0s) → ls output
✓ Print runner OS        (0s) → "Runner OS: Linux"
```

**Failed run (with exit 1):**
```
✓ Checkout code          (1s)
✓ This step works fine   (0s)
✗ This will FAIL         (0s) → exit code: 1
  Subsequent steps skipped
```

---

## What I Learned

1. **`.github/workflows/` is the magic directory** — any `.yml` file in this directory is automatically recognized as a GitHub Actions workflow. No external configuration needed.
2. **`${{ }}` is GitHub's expression syntax** — `${{ github.ref_name }}` is not a shell variable — it's a GitHub expression evaluated by the Actions runner before the shell sees it. It lets you access event data, secrets, and runner info.
3. **Failing fast is the point of CI** — when a step fails, the pipeline stops. This prevents broken code from being deployed. A red pipeline is not a problem — it's CI working as designed, protecting production.
