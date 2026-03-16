# Day 10 Challenge – File Permissions & File Operations

## Files Created

- `devops.txt` – empty file created with `touch`
- `notes.txt` – file with content: "DevOps is awesome"
- `script.sh` – bash script with `echo "Hello DevOps"`
- `project/` – directory with 755 permissions

---

## Commands Used

### Task 1: Create Files

```bash
touch devops.txt
echo "DevOps is awesome" > notes.txt

# script.sh using vim / printf
printf '#!/bin/bash\necho "Hello DevOps"' > script.sh
```

**Initial permissions after creation:**
```
-rw-r--r--. 1 root root  0 Mar  5  devops.txt
-rw-r--r--. 1 root root 18 Mar  5  notes.txt
-rw-r--r--. 1 root root 32 Mar  5  script.sh
```
Default: owner has read+write (`rw-`), group and others have read-only (`r--`).

---

### Task 2: Read Files

```bash
cat notes.txt
# Output: DevOps is awesome

# view script.sh in read-only vim mode
vim -R script.sh

# first 5 lines of /etc/passwd
head -5 /etc/passwd
# root:x:0:0:root:/root:/bin/bash
# bin:x:1:1:bin:/bin:/sbin/nologin
# daemon:x:2:2:daemon:/sbin:/sbin/nologin
# adm:x:3:4:adm:/var/adm:/sbin/nologin
# lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

# last 5 lines of /etc/passwd
tail -5 /etc/passwd
# mongod:x:985:979:mongod:/var/lib/mongo:/bin/false
# tokyo:x:1002:1002::/home/tokyo:/bin/bash
# berlin:x:1003:1003::/home/berlin:/bin/bash
# professor:x:1004:1004::/home/professor:/bin/bash
# nairobi:x:1005:1005::/home/nairobi:/bin/bash
```

---

### Task 3: Understand Permissions

**Format:** `rwxrwxrwx` = owner-group-others
- `r` = read = 4
- `w` = write = 2
- `x` = execute = 1

**Before changes:**
```
-rw-r--r--  devops.txt   → owner: rw-, group: r--, others: r-- (644)
-rw-r--r--  notes.txt    → owner: rw-, group: r--, others: r-- (644)
-rw-r--r--  script.sh    → owner: rw-, group: r--, others: r-- (644)
```

Who can do what on `notes.txt` (644)?
- Owner: read + write
- Group: read only
- Others: read only
- Nobody: execute

---

### Task 4: Modify Permissions

**1. Make `script.sh` executable and run it:**
```bash
chmod +x script.sh
./script.sh
# Output: Hello DevOps
```
After: `-rwxr-xr-x` — execute added for all

**2. Set `devops.txt` read-only:**
```bash
chmod -w devops.txt
ls -l devops.txt
# -r--r--r--. 1 root root 0  devops.txt
```

**3. Set `notes.txt` to 640:**
```bash
chmod 640 notes.txt
ls -l notes.txt
# -rw-r-----. 1 root root 18  notes.txt
```
- Owner: rw- (6)
- Group: r-- (4)
- Others: --- (0)

**4. Create `project/` with 755:**
```bash
mkdir project/
chmod 755 project/
ls -ld project/
# drwxr-xr-x. 2 root root 6  project/
```
- Owner: rwx (7) — can read, write, enter
- Group/Others: r-x (5) — can read and enter, but not create files

---

### Task 5: Test Permissions

**Writing to a read-only file (`devops.txt`):**
```bash
echo "hello" >> devops.txt
# As root: succeeds (root bypasses permission checks)
# As regular user: bash: devops.txt: Permission denied
```
The error means the write bit is missing. Root bypasses file permissions (but not mandatory access control).

**Executing without execute permission:**
```bash
chmod -x script.sh
./script.sh
# bash: ./script.sh: Permission denied
```
Even if you can read the file, without `x`, the OS won't load it as a program.

---

## Permission Changes Summary

| File        | Before      | Change         | After       |
|-------------|-------------|----------------|-------------|
| devops.txt  | -rw-r--r-- | chmod -w        | -r--r--r-- |
| notes.txt   | -rw-r--r-- | chmod 640       | -rw-r----- |
| script.sh   | -rw-r--r-- | chmod +x        | -rwxr-xr-x |
| project/    | drwxr-xr-x | chmod 755       | drwxr-xr-x |

---

## What I Learned

1. **Permission bits are three triplets** — owner/group/others. Missing any bit for the right entity is the source of most "Permission denied" errors.
2. **Numeric (octal) notation is faster** — `chmod 755` is quicker to type than `chmod u=rwx,go=rx` and less error-prone once you memorize: 4=r, 2=w, 1=x.
3. **Root bypasses file permissions** — root can read/write any file regardless of permissions. Dangerous on production systems; use sudo only when needed.
