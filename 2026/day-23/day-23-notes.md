# Day 23 – Git Branching & Working with GitHub

## Task 1: Understanding Branches

### What is a branch in Git?
A branch is a lightweight, movable pointer to a specific commit. When you create a branch, Git creates a new pointer — it doesn't copy files. Branches let you diverge from the main line of development and work independently.

### Why use branches instead of committing everything to `main`?
- **Isolation** — work on a feature without breaking the working `main` branch
- **Parallel development** — multiple developers work on different features simultaneously
- **Code review** — branches enable pull requests so code is reviewed before merging
- **Safe experimentation** — try ideas freely; discard the branch if the idea doesn't work

### What is `HEAD` in Git?
`HEAD` is a pointer to the currently checked-out commit — usually the tip of your current branch. When you switch branches, `HEAD` moves to the tip of that branch. `HEAD` is what tells Git "this is where I am right now."

### What happens to your files when you switch branches?
Git updates the working directory to match the state of the branch you switch to. Files added or changed on the current branch that are committed will "disappear" when switching (they're stored in Git, not deleted). Uncommitted changes may block the switch or carry over.

---

## Task 2: Branching Commands (Hands-On in devops-git-practice repo)

```bash
# List all branches
git branch

# Create branch feature-1
git branch feature-1

# Switch to feature-1
git checkout feature-1
# OR (modern way)
git switch feature-1

# Create AND switch in one command
git switch -c feature-2
# OR (older way)
git checkout -b feature-2

# Make a commit on feature-1
git switch feature-1
echo "Feature 1 work" >> features.txt
git add features.txt
git commit -m "Add feature-1 changes"

# Switch back to main — feature-1 commit not visible here
git switch main
git log --oneline  # feature-1 commit not listed

# Delete a branch (after merging)
git branch -d feature-2

# Force delete (even if unmerged)
git branch -D feature-2
```

### `git switch` vs `git checkout`?
- `git checkout` does too many things: switch branches, restore files, detach HEAD
- `git switch` is the modern command for **only** switching branches — cleaner, harder to accidentally misuse
- Use `git switch` for branch operations, `git restore` for file restoration

---

## Task 3: Push to GitHub

```bash
# Connect local repo to GitHub remote (one time)
git remote add origin https://github.com/username/devops-git-practice.git

# Push main branch
git push -u origin main

# Push feature-1 branch
git push -u origin feature-1

# Verify remote branches
git branch -r
```

### What is the difference between `origin` and `upstream`?

| Term | Meaning |
|------|---------|
| `origin` | Your fork or primary remote — the repo you cloned from or created |
| `upstream` | The original repo (when you've forked someone else's repo) |

**Example workflow:**
- You fork `TrainWithShubham/90DaysOfDevOps` → this becomes `upstream`
- Your fork `yourusername/90DaysOfDevOps` → this is `origin`
- `git pull upstream master` → get latest changes from the original
- `git push origin master` → push your changes to your fork

---

## Task 4: Pull from GitHub

```bash
# Make a change on GitHub via browser, then:
git fetch origin           # download changes, don't merge
git pull origin main       # download + merge (= fetch + merge)
```

### Difference between `git fetch` and `git pull`?

| Command | What it does |
|---------|-------------|
| `git fetch` | Downloads remote changes into `origin/main` — does NOT touch your local files |
| `git pull` | `git fetch` + `git merge` — downloads AND integrates into your current branch |

`git fetch` is safer — it lets you inspect changes before merging. Use `git fetch` + `git log origin/main` to see what changed before merging.

---

## Task 5: Clone vs Fork

```bash
# Clone any public repo
git clone https://github.com/torvalds/linux.git

# Fork on GitHub (click Fork button), then clone YOUR fork
git clone https://github.com/yourusername/linux.git
```

### Differences

| | Clone | Fork |
|---|---|---|
| What it is | Git operation — local copy | GitHub operation — copy on GitHub |
| Where copy lives | Your local machine | Your GitHub account |
| Connection to original | Points to original as `origin` | Your fork is `origin`, original is `upstream` |
| Can you push? | Only if you have permission | Yes, it's your copy |

**When to clone?** Repos you have write access to, or just want to use locally.

**When to fork?** Contributing to someone else's project — you can't push directly to their repo.

### Keep fork in sync with original:
```bash
git remote add upstream https://github.com/originalowner/repo.git
git fetch upstream
git merge upstream/main
git push origin main
```

---

## Git Commands Added to git-commands.md

```bash
git branch                    # list local branches
git branch <name>             # create branch
git switch <name>             # switch to branch
git switch -c <name>          # create + switch
git checkout -b <name>        # create + switch (older)
git branch -d <name>          # delete merged branch
git branch -D <name>          # force delete
git push -u origin <branch>   # push branch to remote
git remote add origin <url>   # add remote
git remote -v                 # list remotes
git fetch origin              # download without merging
git pull origin <branch>      # download + merge
git clone <url>               # clone repo
git branch -r                 # list remote branches
```
