---
name: setup-hooks
description: Set up commitlint and husky git hooks to enforce conventional commits in the current Node.js project
arguments: []
---

# Setup Conventional Commit Hooks

Set up commitlint + husky in the current project to enforce conventional commit messages via git hooks.

## Prerequisites

- The current directory must be a Node.js project (has `package.json`)
- The current directory must be a git repository

## Steps

### 1. Detect package manager

Check which package manager the project uses by looking for lock files:

| Lock file | Package manager |
|-----------|----------------|
| `bun.lockb` or `bun.lock` | bun |
| `pnpm-lock.yaml` | pnpm |
| `yarn.lock` | yarn |
| `package-lock.json` | npm |

If none found, default to `npm`.

### 2. Install dependencies

Install as dev dependencies:

- `@commitlint/cli`
- `@commitlint/config-conventional`
- `husky`

Use the detected package manager's install command (e.g., `npm install -D`, `pnpm add -D`, `yarn add -D`, `bun add -d`).

### 3. Initialize husky

Run the husky init command:

```bash
npx husky init
```

This creates the `.husky/` directory and adds a `prepare` script to `package.json`.

### 4. Create commit-msg hook

Write the following to `.husky/commit-msg`:

```bash
npx --no -- commitlint --edit "$1"
```

### 5. Create pre-push hook

Write the following to `.husky/pre-push`:

```bash
#!/usr/bin/env bash

remote="$1"

# Read each ref being pushed from stdin
while read local_ref local_oid remote_ref remote_oid; do
  # Skip delete pushes
  if [ "$local_oid" = "0000000000000000000000000000000000000000" ]; then
    continue
  fi

  # Determine the range of commits to check
  if [ "$remote_oid" = "0000000000000000000000000000000000000000" ]; then
    # New branch — check all commits not on the remote default branch
    range="$local_oid --not --remotes=$remote"
  else
    range="$remote_oid..$local_oid"
  fi

  # Validate each commit message in the range
  for sha in $(git rev-list $range); do
    git log -1 --format='%B' "$sha" | npx --no -- commitlint
    if [ $? -ne 0 ]; then
      echo ""
      echo "ERROR: Commit $sha does not follow the Conventional Commits format."
      echo "Fix the commit message before pushing (e.g., git rebase -i)."
      exit 1
    fi
  done
done
```

### 6. Create commitlint config

Write `commitlint.config.mjs` to the project root:

```javascript
export default { extends: ['@commitlint/config-conventional'] };
```

### 7. Verify setup

Run a quick validation to confirm everything is wired up:

```bash
echo "bad message" | npx --no -- commitlint
```

This should fail. Then:

```bash
echo "feat: test message" | npx --no -- commitlint
```

This should pass. Report the results to the user.
