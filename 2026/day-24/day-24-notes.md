# Day 24 – Advanced Git: Merge, Rebase, Stash & Cherry Pick

## Task 1: Git Merge

### Hands-On Practice

```bash
# Create feature-login branch, add commits
git switch -c feature-login
echo "Login page" >> login.html
git add . && git commit -m "Add login page"
echo "Login validation" >> login.html
git add . && git commit -m "Add login validation"

# Switch to main and merge
git switch main
git merge feature-login
```

### Fast-forward merge
Happens when `main` has not moved ahead since branching. Git simply moves `main`'s pointer forward to the branch tip. No merge commit is created — history stays linear.

```
Before:  main → A → B
                    └── feature-login → C → D

After:   main → A → B → C → D   (HEAD moved forward)
```

### Merge commit
Happens when both `main` and the feature branch have new commits. Git creates a new commit with two parents to record the merge.

```bash
# To force a merge commit even for fast-forward
git merge --no-ff feature-login
```

```
Before:  main → A → B → E
                    └── feature-signup → C → D

After:   main → A → B → E → M (merge commit)
                    └── C → D ┘
```

### What is a merge conflict?
A conflict occurs when the same line in the same file was changed differently on both branches. Git can't auto-decide which change to keep.

```bash
# Intentionally create a conflict:
# On main: echo "Line from main" > conflict.txt && git commit
# On feature: echo "Line from feature" > conflict.txt && git commit
# Then: git merge feature  → CONFLICT!

git status       # shows conflicted files
# Edit the file, remove <<<<, ====, >>>> markers
git add conflict.txt
git commit       # complete the merge
```

---

## Task 2: Git Rebase

```bash
# Start: main at commit E, feature-dashboard at commit D
git switch -c feature-dashboard
git commit -m "Dashboard layout" --allow-empty
git commit -m "Dashboard widgets" --allow-empty

# Add commit to main (main moves ahead)
git switch main
git commit -m "Hotfix on main" --allow-empty

# Rebase feature-dashboard onto updated main
git switch feature-dashboard
git rebase main
```

### What does rebase do?
Rebase **replays** your commits on top of the target branch. It creates NEW commits (with new hashes) that have the same changes but a different parent.

```
Before rebase:
  main: A → B → C → E (hotfix)
  feature-dashboard: A → B → C → D1 → D2

After rebase:
  feature-dashboard: A → B → C → E → D1' → D2'
  (D1' and D2' are new commits with same changes but new parents)
```

### Merge vs Rebase history

| Merge | Rebase |
|-------|--------|
| Preserves history exactly | Rewrites history — linear |
| Shows when branches diverged | Looks like everything was always on one branch |
| Safe for shared branches | NEVER rebase shared/pushed commits |

### Why never rebase pushed commits?
When you rebase, commits get new hashes. If teammates pulled the old commits, their history now diverges from yours. This creates a mess that's very hard to untangle.

**Rule:** Rebase locally before pushing. Never rebase after pushing.

---

## Task 3: Squash Merge

```bash
# feature-profile has 5 noisy commits (typo fixes, formatting)
git switch main
git merge --squash feature-profile
git commit -m "Add user profile feature"  # one clean commit
git log --oneline   # only one new commit on main
```

### Squash vs Regular Merge

| | Squash Merge | Regular Merge |
|---|---|---|
| Commits added to main | 1 (all squashed) | All branch commits |
| History | Clean, one commit per feature | Full history preserved |
| When to use | Small/noisy features, clean PR history | Long-running features with important history |
| Trade-off | Lose individual commit context | Can clutter main's history |

---

## Task 4: Git Stash

```bash
# Start editing, get interrupted
echo "WIP changes" >> app.js

# Can't switch branches with uncommitted changes — use stash
git stash
git switch hotfix-branch
# Do urgent work...
git switch main

# Restore stashed work
git stash pop        # apply + remove from stash list
# OR
git stash apply      # apply but KEEP in stash list

# Multiple stashes
git stash push -m "WIP: dashboard redesign"
git stash push -m "WIP: login refactor"
git stash list
# stash@{0}: On main: WIP: login refactor
# stash@{1}: On main: WIP: dashboard redesign

# Apply specific stash
git stash apply stash@{1}
```

### `git stash pop` vs `git stash apply`

| | pop | apply |
|---|---|---|
| Applies stash? | Yes | Yes |
| Removes from stash list? | Yes | No |
| Use when | You're done with this stash | You want to apply to multiple branches |

---

## Task 5: Cherry Pick

```bash
# feature-hotfix has 3 commits: A, B, C
# We only want commit B on main

git log feature-hotfix --oneline
# abc1234 Fix critical null pointer in auth (commit C)
# def5678 Update rate limiter config (commit B — we want this!)
# ghi9012 Add new feature flag (commit A)

git switch main
git cherry-pick def5678

git log --oneline  # def5678's changes now on main as a new commit
```

### What does cherry-pick do?
Copies a single commit from any branch and applies it to your current branch. Creates a new commit with the same changes but a different hash.

### When to use cherry-pick?
- A bug was fixed on a feature branch and needs to go to production immediately
- You want one specific commit from a long-running branch without taking everything else
- Backporting a fix to an older release branch

### What can go wrong?
- Conflicts — if the context around the change differs between branches
- Duplicate commits — if the original branch is later merged, that commit appears twice in history (with different hashes)
- Lost context — cherry-picked commits may depend on other commits that aren't present

---

## Visualize Everything

```bash
git log --oneline --graph --all
# Shows all branches and their relationships in ASCII art
```

---

## Git Commands Added to git-commands.md

```bash
git merge <branch>          # merge branch into current
git merge --no-ff <branch>  # force merge commit
git merge --squash <branch> # squash all commits into one
git rebase <branch>         # replay commits on top of branch
git rebase --abort          # abort a rebase in progress
git rebase --continue       # continue after resolving conflicts
git stash                   # stash current changes
git stash push -m "msg"     # stash with description
git stash list              # show all stashes
git stash pop               # apply and remove top stash
git stash apply stash@{n}   # apply specific stash
git stash drop stash@{n}    # delete specific stash
git cherry-pick <hash>      # apply specific commit to current branch
```
