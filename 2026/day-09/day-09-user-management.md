# Day 09 Challenge – Linux User & Group Management

## Users & Groups Created

### Users
- `tokyo` – regular developer user
- `berlin` – developer with admin access
- `professor` – admin-only user
- `nairobi` – project team member

### Groups
- `developers` – for development team members
- `admins` – for users with elevated access
- `project-team` – for cross-functional project members

---

## Commands Used

### Task 1: Create Users with Home Directories

```bash
useradd -m tokyo
useradd -m berlin
useradd -m professor
useradd -m nairobi
```

**Verify:** Check `/etc/passwd` and home directories
```bash
grep -E "^tokyo:|^berlin:|^professor:|^nairobi:" /etc/passwd
ls /home/
```

**Output:**
```
tokyo:x:1002:1002::/home/tokyo:/bin/bash
berlin:x:1003:1003::/home/berlin:/bin/bash
professor:x:1004:1004::/home/professor:/bin/bash
nairobi:x:1005:1005::/home/nairobi:/bin/bash
```

---

### Task 2: Create Groups

```bash
groupadd developers
groupadd admins
groupadd project-team
```

**Verify:** Check `/etc/group`
```bash
grep -E "^developers:|^admins:|^project-team:" /etc/group
```

**Output:**
```
developers:x:1006:
admins:x:1007:
project-team:x:1008:
```

---

### Task 3: Assign Users to Groups

```bash
usermod -aG developers tokyo
usermod -aG developers berlin
usermod -aG admins berlin       # berlin is in BOTH developers + admins
usermod -aG admins professor
usermod -aG project-team nairobi
usermod -aG project-team tokyo
```

**Verify group membership:**
```bash
groups tokyo     # tokyo : tokyo developers project-team
groups berlin    # berlin : berlin developers admins
groups professor # professor : professor admins
groups nairobi   # nairobi : nairobi project-team
```

---

### Task 4: Shared Directory for `developers`

```bash
mkdir -p /opt/dev-project
chgrp developers /opt/dev-project
chmod 775 /opt/dev-project
```

**Verify:**
```bash
ls -ld /opt/dev-project
# drwxrwxr-x. 2 root developers 6 Mar 5 /opt/dev-project
```

- Owner (`root`): rwx
- Group (`developers`): rwx  — tokyo and berlin can read/write
- Others: r-x — read only

**Test file creation:**
```bash
sudo -u tokyo touch /opt/dev-project/tokyo-file.txt
sudo -u berlin touch /opt/dev-project/berlin-file.txt
ls -l /opt/dev-project/
```

---

### Task 5: Team Workspace

```bash
mkdir -p /opt/team-workspace
chgrp project-team /opt/team-workspace
chmod 775 /opt/team-workspace
```

**Verify:**
```bash
ls -ld /opt/team-workspace
# drwxrwxr-x. 2 root project-team 6 Mar 5 /opt/team-workspace
```

**Test file creation as `nairobi`:**
```bash
sudo -u nairobi touch /opt/team-workspace/nairobi-task.txt
ls -l /opt/team-workspace/
```

---

## Group Assignments Summary

| User      | Groups                         |
|-----------|-------------------------------|
| tokyo     | developers, project-team      |
| berlin    | developers, admins            |
| professor | admins                        |
| nairobi   | project-team                  |

---

## Directories Created

| Directory          | Group Owner  | Permissions | Meaning               |
|--------------------|--------------|-------------|----------------------|
| /opt/dev-project   | developers   | 775         | Group can write       |
| /opt/team-workspace| project-team | 775         | Group can write       |

---

## What I Learned

1. **`useradd -m`** is essential — without `-m`, no home directory is created, which breaks many applications that expect `~` to exist.
2. **`usermod -aG`** — the `-a` (append) flag is critical. Without it, `usermod -G group user` *replaces* all the user's groups, which can accidentally revoke access.
3. **Group permissions make shared directories work** — by setting `chmod 775` and assigning the directory to a group, multiple users can collaborate without touching each other's file ownership.
