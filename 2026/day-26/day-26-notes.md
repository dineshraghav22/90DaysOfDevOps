# Day 26 – GitHub CLI: Manage GitHub from Your Terminal

## Task 1: Install and Authenticate

```bash
# Install on Oracle Linux / RHEL / CentOS
sudo dnf install 'dnf-command(config-manager)'
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install gh

# Install on Ubuntu/Debian
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update && sudo apt install gh

# Authenticate
gh auth login
# Choose: GitHub.com → HTTPS → Authenticate with browser (or token)

# Verify
gh auth status
# ✓ Logged in to github.com as yourusername
```

**Authentication methods `gh` supports:**
- Browser OAuth (opens browser, pastes code)
- Personal Access Token (PAT)
- SSH key (for SSH-based auth)

---

## Task 2: Working with Repositories

```bash
# Create a new public repo with README
gh repo create my-devops-lab --public --add-readme --description "DevOps practice repo"

# Clone using gh (fetches SSH or HTTPS based on your auth)
gh repo clone yourusername/my-devops-lab

# View repo details
gh repo view yourusername/my-devops-lab

# List all your repos
gh repo list

# Open repo in browser
gh repo view --web

# Delete a repo (careful!)
gh repo delete yourusername/my-devops-lab --confirm
```

---

## Task 3: Issues

```bash
# Create an issue
gh issue create \
  --title "Fix login bug" \
  --body "Users can't login with special characters in passwords" \
  --label "bug"

# List open issues
gh issue list

# View specific issue
gh issue view 1

# Close an issue
gh issue close 1

# Add a comment
gh issue comment 1 --body "Fixed in PR #5"
```

**How to use `gh issue` in scripts/automation:**
```bash
# Create an issue if health check fails
if ! curl -sf http://myapp.com/health; then
    gh issue create \
      --repo myorg/myapp \
      --title "Health check failed $(date)" \
      --body "Automated alert: health endpoint returned non-200"
fi
```

---

## Task 4: Pull Requests

```bash
# Create PR entirely from terminal
git switch -c feature/add-readme
echo "# My App" >> README.md
git add README.md && git commit -m "Add README"
git push -u origin feature/add-readme

# Create PR (--fill auto-uses commit message as title/body)
gh pr create --fill
# OR manually
gh pr create --title "Add README" --body "Adds project documentation" --base main

# List open PRs
gh pr list

# View PR details (status, checks, reviewers)
gh pr view 1

# Merge PR
gh pr merge 1 --merge     # regular merge
gh pr merge 1 --squash    # squash merge
gh pr merge 1 --rebase    # rebase merge
```

**Merge methods `gh pr merge` supports:** `--merge`, `--squash`, `--rebase`

**Review someone else's PR:**
```bash
gh pr checkout 5         # checkout the PR branch locally
# Test the changes
gh pr review 5 --approve --body "LGTM!"
# OR
gh pr review 5 --request-changes --body "Please fix the null check"
```

---

## Task 5: GitHub Actions & Workflows

```bash
# List workflow runs on a repo
gh run list --repo kubernetes/kubernetes

# View a specific workflow run
gh run view 1234567890

# Watch a run in progress
gh run watch 1234567890

# List all workflows
gh workflow list --repo torvalds/linux

# Trigger a workflow manually
gh workflow run "CI Pipeline" --ref main
```

**How `gh run` and `gh workflow` help in CI/CD:**
- **Debug failed pipelines** without leaving terminal: `gh run view --log-failed`
- **Automated re-runs**: `gh run rerun <run-id>` after fixing a flaky test
- **Script CI checks**: poll `gh run list --status in_progress` before deploying

---

## Task 6: Useful `gh` Tricks

```bash
# Raw GitHub API calls
gh api /repos/torvalds/linux | jq '.stargazers_count'

# Create a Gist
gh gist create script.sh --public --desc "My useful script"

# Create a release
gh release create v1.0.0 --title "Initial Release" --notes "First stable version"

# Custom alias
gh alias set prs 'pr list'   # gh prs → gh pr list
gh alias set myissues 'issue list --assignee @me'

# Search repos
gh search repos "devops kubernetes" --language yaml --sort stars
```

---

## Commands Added to git-commands.md

```bash
gh auth login                         # authenticate
gh auth status                        # check login status
gh repo create <name> --public        # create repo
gh repo clone <owner>/<repo>          # clone repo
gh repo list                          # list your repos
gh repo view --web                    # open in browser
gh issue create --title "" --body ""  # create issue
gh issue list                         # list issues
gh issue close <number>               # close issue
gh pr create --fill                   # create PR
gh pr list                            # list PRs
gh pr merge <number> --squash         # merge PR
gh pr checkout <number>               # checkout PR branch
gh run list                           # list workflow runs
gh run view <id>                      # view run details
gh workflow list                      # list workflows
gh api /path                          # raw API call
gh gist create <file>                 # create gist
```
