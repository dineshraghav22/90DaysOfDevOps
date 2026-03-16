# Day 11 Challenge – File Ownership (chown & chgrp)

## Files & Directories Created

- `devops-file.txt` – ownership changed to user `tokyo`
- `team-notes.txt` – group changed to `heist-team`
- `project-config.yaml` – owner: `professor`, group: `heist-team`
- `app-logs/` – owner: `berlin`, group: `heist-team`
- `heist-project/` – recursive ownership to `professor:planners`
  - `heist-project/vault/gold.txt`
  - `heist-project/plans/strategy.conf`
- `bank-heist/` – individual ownership per file

---

## Commands Used

### Task 1: Understanding Ownership

```bash
ls -l /home/
# Format: -rw-r--r-- 1 owner group size date filename
```

**Difference between owner and group:**
- **Owner** – the single user who "owns" the file; usually who created it. The owner can change permissions.
- **Group** – a set of users sharing access. Useful for collaboration without giving full owner access.

---

### Task 2: Basic chown – Change Owner

```bash
touch devops-file.txt
ls -l devops-file.txt
# -rw-r--r--. 1 root root 0  devops-file.txt   (initial: root owns it)

sudo chown tokyo devops-file.txt
ls -l devops-file.txt
# -rw-r--r--. 1 tokyo root 0  devops-file.txt

sudo chown berlin devops-file.txt
ls -l devops-file.txt
# -rw-r--r--. 1 berlin root 0  devops-file.txt
```

---

### Task 3: Basic chgrp – Change Group

```bash
touch team-notes.txt
sudo groupadd heist-team
sudo chgrp heist-team team-notes.txt
ls -l team-notes.txt
# -rw-r--r--. 1 root heist-team 0  team-notes.txt
```

---

### Task 4: Combined Owner & Group Change

```bash
touch project-config.yaml
sudo chown professor:heist-team project-config.yaml
ls -l project-config.yaml
# -rw-r--r--. 1 professor heist-team 0  project-config.yaml

mkdir app-logs/
sudo chown berlin:heist-team app-logs/
ls -ld app-logs/
# drwxr-xr-x. 2 berlin heist-team 6  app-logs/
```

---

### Task 5: Recursive Ownership

```bash
mkdir -p heist-project/vault
mkdir -p heist-project/plans
touch heist-project/vault/gold.txt
touch heist-project/plans/strategy.conf

sudo groupadd planners
sudo chown -R professor:planners heist-project/
ls -lR heist-project/
```

**Output:**
```
heist-project/:
drwxr-xr-x. 2 professor planners 27  plans
drwxr-xr-x. 2 professor planners 22  vault

heist-project/plans:
-rw-r--r--. 1 professor planners 0   strategy.conf

heist-project/vault:
-rw-r--r--. 1 professor planners 0   gold.txt
```

The `-R` flag recursively changed every file and subdirectory — all now owned by `professor:planners`.

---

### Task 6: Practice Challenge

```bash
mkdir bank-heist/
touch bank-heist/access-codes.txt bank-heist/blueprints.pdf bank-heist/escape-plan.txt

sudo groupadd vault-team
sudo groupadd tech-team

sudo chown tokyo:vault-team bank-heist/access-codes.txt
sudo chown berlin:tech-team bank-heist/blueprints.pdf
sudo chown nairobi:vault-team bank-heist/escape-plan.txt

ls -l bank-heist/
```

**Output:**
```
-rw-r--r--. 1 tokyo   vault-team 0  access-codes.txt
-rw-r--r--. 1 berlin  tech-team  0  blueprints.pdf
-rw-r--r--. 1 nairobi vault-team 0  escape-plan.txt
```

---

## Ownership Changes Summary

| File/Dir                     | Before          | After                  |
|------------------------------|-----------------|------------------------|
| devops-file.txt              | root:root       | tokyo:root             |
| team-notes.txt               | root:root       | root:heist-team        |
| project-config.yaml          | root:root       | professor:heist-team   |
| app-logs/                    | root:root       | berlin:heist-team      |
| heist-project/ (all files)   | root:root       | professor:planners     |
| bank-heist/access-codes.txt  | root:root       | tokyo:vault-team       |
| bank-heist/blueprints.pdf    | root:root       | berlin:tech-team       |
| bank-heist/escape-plan.txt   | root:root       | nairobi:vault-team     |

---

## Key Commands Reference

```bash
# View ownership
ls -l filename

# Change owner only
sudo chown newowner filename

# Change group only
sudo chgrp newgroup filename

# Change both owner and group
sudo chown owner:group filename

# Recursive change
sudo chown -R owner:group directory/

# Change group only using chown
sudo chown :groupname filename
```

---

## What I Learned

1. **`chown owner:group`** does the job of both `chown` and `chgrp` in one command — always prefer this for efficiency.
2. **`-R` (recursive) is powerful but dangerous** — double-check the target directory before using it. A wrong path with `-R` can silently break permissions across a whole tree.
3. **File ownership matters for DevOps deployments** — web servers like nginx run as `www-data` or `nginx` user; if your app files are owned by a different user, the server can't read them. Always match file ownership to the running process user.
