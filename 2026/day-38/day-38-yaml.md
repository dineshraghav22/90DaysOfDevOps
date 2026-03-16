# Day 38 – YAML Basics

## YAML Files Created

1. `person.yaml` — key-values, lists (block and inline)
2. `server.yaml` — nested objects, multi-line strings

---

## Task 1 & 2: Key-Value Pairs & Lists – person.yaml

```yaml
name: Dinesh
role: DevOps Engineer
experience_years: 2
learning: true

# Block list (one item per line)
tools:
  - docker
  - kubernetes
  - git
  - bash
  - linux

# Inline list (all on one line)
hobbies: [reading, coding, hiking]
```

**Validation:**
```python
import yaml
with open('person.yaml') as f:
    data = yaml.safe_load(f)
# {'name': 'Dinesh', 'role': 'DevOps Engineer', 'experience_years': 2,
#  'learning': True, 'tools': [...], 'hobbies': [...]}
```

**Two ways to write a YAML list:**
1. **Block style:** each item on its own line prefixed with `- ` (two chars: dash + space)
2. **Flow/inline style:** comma-separated items in square brackets `[item1, item2]`

---

## Task 3 & 4: Nested Objects & Multi-line Strings – server.yaml

```yaml
server:
  name: database_vip
  ip: 172.16.115.78
  port: 3306

database:
  host: localhost
  name: appdb
  credentials:
    user: appuser
    password: "ch@nge_me_in_production"   # quotes needed for @

# | = literal block: preserves newlines exactly
startup_script: |
  #!/bin/bash
  echo "Starting server..."
  systemctl start mariadb
  echo "Server started."

# > = folded block: newlines become spaces (one long line)
description: >
  This is a production database server
  running MariaDB and Nginx.
  It serves the main application backend.
```

### `|` vs `>` — when to use each?

| Style | Preserves newlines? | Best for |
|-------|--------------------|-|
| `|` (literal) | Yes | Scripts, code snippets, text that needs line breaks |
| `>` (folded) | No (→ spaces) | Long descriptions, prose text |

---

## Task 5: Validation

```bash
# Install yamllint
pip install yamllint

# Validate
yamllint person.yaml
yamllint server.yaml
```

**Intentionally broken indentation:**
```yaml
# This is WRONG:
tools:
- docker
  - kubernetes     # inconsistent indentation = YAML error
```

Error: `yaml.scanner.ScannerError: mapping values are not allowed here`

**Fixed:**
```yaml
tools:
  - docker
  - kubernetes     # both items at same indentation level
```

---

## Task 6: Spot the Difference

```yaml
# Block 1 - CORRECT
name: devops
tools:
  - docker
  - kubernetes
```

```yaml
# Block 2 - BROKEN
name: devops
tools:
- docker
  - kubernetes   # WRONG: kubernetes is 2 spaces in from tools, docker is at same level as tools
```

**What's wrong with Block 2:**
`- docker` is not indented (same level as `tools`), treating it as a top-level key, not a list item. `- kubernetes` is then orphaned with incorrect relative indentation. The list items need to be uniformly indented under `tools`.

---

## YAML Rules Summary

1. **Spaces only, never tabs** — tabs cause `yaml.scanner.ScannerError`
2. **2 spaces for indentation** — standard across most YAML consumers
3. **Consistent indentation** — all items in a list at the same level
4. **Quote strings with special chars** — `:`, `#`, `@`, `{`, `}` need quotes
5. **`true`/`false` are booleans** — `"true"` is a string, `true` is boolean
6. **`|` preserves newlines** — use for scripts and multi-line content
7. **`>` folds to single line** — use for long prose descriptions

---

## What I Learned

1. **YAML is sensitive but readable** — the indentation-as-structure approach makes YAML very clean to read but very unforgiving to write. One wrong space breaks everything.
2. **Multi-line strings are powerful for DevOps** — storing shell scripts, SQL, or config blocks as YAML fields using `|` is common in Kubernetes ConfigMaps and GitHub Actions workflows.
3. **Validate before deploying** — a YAML error in a CI/CD pipeline or Kubernetes manifest causes confusing failures. Always validate with `yamllint` or `python3 -c "import yaml; yaml.safe_load(open('file.yaml'))"` before committing.
