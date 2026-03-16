# Day 27 – GitHub Profile Makeover: Build Your Developer Identity

## Task 1: GitHub Profile Audit

Before making changes, assessed the profile as a stranger would see it:

| Check | Before | After |
|-------|--------|-------|
| Profile picture | Generic avatar | Professional photo |
| Bio | Empty | "DevOps learner | Linux, Docker, Git | #90DaysOfDevOps" |
| Pinned repos | Random forks | Best 6 relevant repos |
| Repo descriptions | Missing | All repos have descriptions |
| README | None | Profile README created |

**Honest assessment before changes:**
- No bio — a recruiter can't tell what I do in 2 seconds
- Old forks pinned — shows nothing about current skills
- Most repos have no descriptions or README
- No clear story about what I'm learning or building

---

## Task 2: Profile README

Created the special repo `yourusername/yourusername` with this `README.md`:

```markdown
## Hey, I'm Dinesh 👋

DevOps learner on the #90DaysOfDevOps journey.

**Currently working on:**
- 90 Days of DevOps (2026 edition) — Day 27 of 90
- Building CI/CD pipelines with GitHub Actions
- Containerizing apps with Docker and Compose

**Skills & Tools:**
- Linux (Oracle Linux, Ubuntu) | Bash Scripting
- Git & GitHub | Docker | YAML
- Networking fundamentals | LVM | systemd

**Learning next:** Kubernetes, Terraform, AWS

**Connect:** [LinkedIn](https://linkedin.com/in/yourprofile) | dinesh@email.com

📂 **Key Repos:**
- [90DaysOfDevOps](link) — Daily DevOps learning submissions
- [shell-scripts](link) — Production-ready bash scripts
- [devops-notes](link) — Cheat sheets and reference docs
```

**Tips applied:**
- Kept it under 20 lines
- Used headers and bullets — no paragraphs
- Shows what I'm DOING, not just what I know
- Minimal badges (none) — substance over decoration

---

## Task 3: Repository Organization

Created and organized these repos:

### 90DaysOfDevOps (fork)
- **README:** Explains the challenge, links to TrainWithShubham
- **Structure:** `2026/day-01/` through `2026/day-90/`
- **Description:** "My submissions for the 90 Days of DevOps 2026 challenge"

### shell-scripts
- Contains: `log_rotate.sh`, `backup.sh`, `system_info.sh`, `log_analyzer.sh`
- **README:** Lists each script, what it does, and usage example
- **Description:** "Production-ready bash scripts for Linux automation"

### devops-notes
- Contains: `shell-scripting-cheatsheet.md`, `git-commands.md`, `docker-cheatsheet.md`
- **Structure:** Organized by topic
- **Description:** "DevOps cheat sheets and reference guides"

**For every repo:**
```
✓ Descriptive name (kebab-case)
✓ One-line description on GitHub
✓ README.md with what's inside and how to use it
✓ .gitignore for the appropriate language/tool
```

---

## Task 4: Pinned Repositories

Selected 6 pinned repos that best represent current work:
1. `90DaysOfDevOps` — ongoing challenge submissions
2. `shell-scripts` — practical automation tools
3. `devops-notes` — reference documentation
4. `devops-git-practice` — Git learning repo
5. Any Python project
6. Any web/app project

---

## Task 5: Cleanup Done

- Deleted 3 empty repos that were never used
- Renamed 2 repos from vague names to descriptive ones
- Verified no `.env` files or API keys in any commit history
- Checked with: `git log --all --full-history -- "**/.env"` — none found

**Check for secrets:**
```bash
# Scan for accidentally committed secrets
git log --all --full-history -- "**/.env"
git log --all --full-history -- "**/credentials*"
git log --all --full-history -- "**/*.pem"
```

---

## 3 Things Improved

1. **Profile README** — went from invisible to telling my story in < 15 lines. Recruiters now know what I do, what I'm learning, and how to reach me.
2. **Repo descriptions** — every repo now has a one-line description visible in search results and profile. No more blank repos.
3. **Pinned repos** — selected repos that show my actual DevOps learning, not random archived forks from years ago.

---

## Key Insight

Your GitHub is not a backup drive — it's your portfolio. Every empty repo, missing README, and blank description is a missed opportunity to show what you can do. Treat each repo like a mini project page.
