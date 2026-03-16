# Day 25 – Git Reset vs Revert & Branching Strategies

## Task 1: Git Reset

### Hands-On

```bash
# Make 3 commits
echo "A" >> file.txt && git add . && git commit -m "Commit A"
echo "B" >> file.txt && git add . && git commit -m "Commit B"
echo "C" >> file.txt && git add . && git commit -m "Commit C"

git log --oneline
# abc1234 Commit C
# def5678 Commit B
# ghi9012 Commit A
```

**`git reset --soft HEAD~1`**
```bash
git reset --soft HEAD~1
# Result: Commit C is gone from history, but changes are STAGED
git status  # → "Changes to be committed: file.txt"
# The C changes are ready to recommit
```

**`git reset --mixed HEAD~1`** (default)
```bash
git reset HEAD~1
# Result: Commit gone, changes are UNSTAGED (in working directory)
git status  # → "Changes not staged for commit: file.txt"
# Must git add again before committing
```

**`git reset --hard HEAD~1`**
```bash
git reset --hard HEAD~1
# Result: Commit gone AND changes are DESTROYED from working directory
git status  # → "nothing to commit, working tree clean"
# The C changes are GONE (unless you use git reflog)
```

### Differences

| Mode | Commit removed? | Changes staged? | Changes in working dir? |
|------|----------------|-----------------|------------------------|
| `--soft` | Yes | Yes (staged) | Yes |
| `--mixed` | Yes | No | Yes (unstaged) |
| `--hard` | Yes | No | No (GONE) |

### Which is destructive?
`--hard` is destructive — it removes both the commit and the working directory changes. Once done, there's no easy undo (only `git reflog` can help).

### When to use each?
- `--soft` — undo a commit but keep the work staged (ready to recommit with a better message)
- `--mixed` — undo a commit and unstage the changes (start over with what to commit)
- `--hard` — throw away the last commit completely (dangerous; only on truly unwanted work)

### Should you reset pushed commits?
**No.** Reset rewrites history. If teammates pulled your commit, they now have history that doesn't match yours. Use `git revert` instead.

---

## Task 2: Git Revert

```bash
# Make 3 commits: X, Y, Z
git log --oneline
# zz12345 Commit Z
# yy67890 Commit Y (the one we want to undo)
# xx11111 Commit X

# Revert Y (the middle commit)
git revert yy67890
# Git opens editor for commit message, save it
# Creates new commit: "Revert 'Commit Y'"

git log --oneline
# rr99999 Revert "Commit Y"    ← new commit
# zz12345 Commit Z
# yy67890 Commit Y             ← still in history!
# xx11111 Commit X
```

**Is commit Y still in history?** Yes — `git revert` never removes commits. It creates a new commit that undoes the changes. The history is preserved.

### How `git revert` differs from `git reset`

| | `git revert` | `git reset` |
|---|---|---|
| Removes commit from history? | No | Yes |
| Creates new commit? | Yes (an "undo" commit) | No |
| Safe for shared branches? | Yes | No |
| Can undo pushed commits? | Yes | Dangerous |

### Why is revert safer for shared branches?
Because it doesn't rewrite history — everyone's `git pull` continues to work. The undo is just another commit that teammates can pull normally.

---

## Task 3: Reset vs Revert Comparison Table

| | `git reset` | `git revert` |
|---|---|---|
| What it does | Moves branch pointer back | Creates a new "undo" commit |
| Removes commit from history? | Yes | No |
| Safe for shared/pushed branches? | No — rewrites history | Yes — adds to history |
| When to use | Local cleanup, before pushing | After pushing, on shared branches |

---

## Task 4: Branching Strategies

### 1. GitFlow

**How it works:**
- Two permanent branches: `main` (production) and `develop` (integration)
- Feature branches off `develop`, merged back to `develop`
- Release branches when ready to ship (merged to `main` + `develop`)
- Hotfix branches off `main` for emergency fixes

```
main:     ─────────────────────────── M1 ─────────── M2
develop:  ─── ─── ─── ─── ─── ─── ─── D1 ─── ─── ─── D2
feature:       F ──── F ──── F ┘
release:                             R ─── R ─┤
hotfix:                                          H ─┤
```

**When used:** Teams with scheduled release cycles (bi-weekly, monthly).
**Pros:** Clear structure, separates development from production.
**Cons:** Complex, many long-lived branches, overhead for small teams.

---

### 2. GitHub Flow

**How it works:**
- Only one permanent branch: `main`
- Create a feature branch → commit → open PR → review → merge → deploy

```
main:    A ─── B ─────────────────── E (deploy)
feature:       └─── C ─── D ─── ┘ (PR merged)
```

**When used:** Startups, SaaS products, teams deploying continuously.
**Pros:** Simple, fast, easy to understand.
**Cons:** Requires good test coverage, risky without strong CI.

---

### 3. Trunk-Based Development

**How it works:**
- Everyone commits directly to `main` (trunk)
- Short-lived feature branches (max 1-2 days), merged frequently
- Feature flags control what users see
- CI pipeline runs on every commit

```
main:    A ─── B ─── C ─── D ─── E ─── F (everyone here)
branch:        └─ b ─┘ (merged in < 1 day)
```

**When used:** High-performing teams (Google, Facebook), microservices.
**Pros:** Minimal merge conflicts, continuous integration is truly continuous.
**Cons:** Needs discipline, feature flags, strong automated testing.

---

### Which strategy for which scenario?

| Scenario | Recommended Strategy |
|----------|---------------------|
| Startup shipping fast | GitHub Flow |
| Large team, scheduled releases | GitFlow |
| High-performance team, microservices | Trunk-Based Development |

**Open-source example:** Kubernetes uses a variant of GitFlow with release branches (`release-1.28`, `release-1.29`) while development happens on `main`.

---

## Task 5: Complete git-commands.md Reference

Added to `git-commands.md` in the `devops-git-practice` repo:

```bash
# === RESET & REVERT ===
git reset --soft HEAD~1    # undo commit, keep changes staged
git reset --mixed HEAD~1   # undo commit, unstage changes
git reset --hard HEAD~1    # undo commit, DESTROY changes (dangerous!)
git revert <hash>          # create new commit that undoes <hash>
git reflog                 # show all Git operations (your safety net)

# === VIEWING HISTORY ===
git log --oneline --graph --all   # visual branch history
git log --oneline -10             # last 10 commits
git show <hash>                   # show a specific commit's changes
git diff main..feature            # diff between branches
```
