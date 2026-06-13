---
name: opencode-config
description: Manage OpenCode configuration files and deployment procedures, including auto-commit workflows and container restarts. Load this skill when modifying OpenCode configuration.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: opencode
---

# OpenCode Configuration Management Skill

## Overview

This skill provides guidance on managing OpenCode configuration files and deployment procedures, including auto-commit workflows and container restarts.

## Auto-commit on Configuration Changes

Whenever you modify any file inside `/root/.config/opencode`, you MUST immediately perform the following steps:

### Step 1: Stage and Commit Changes

```bash
cd /root/.config/opencode && git add -A && git commit -m "config: <brief description of change>"
```

Example commit messages:
- `config: update portainer CLI documentation`
- `config: add new GitHub ops skill`
- `config: refactor AGENTS.md with skill references`

### Step 2: Push Changes to GitHub

After committing, you MUST push the changes to GitHub using:

```bash
cd /root/.config/opencode && git -c credential.helper='!echo "username=git"; echo "password=${GHUB_PAT}"' push
```

Or if git credentials are pre-configured:

```bash
cd /root/.config/opencode && git push
```

## Restart OpenCode Container

After successfully pushing changes to GitHub from `/root/.config/opencode`, you MUST restart the OpenCode container via Portainer CLI.

### Method 1: Restart by container name

```bash
portainerctl container restart opencode --env 3
```

### Method 2: Find container ID and restart

First, find the container ID:

```bash
portainerctl container list --env 3 -o json | jq '.[] | select(.name | contains("opencode")) | .id'
```

Then restart by ID:

```bash
portainerctl container restart <container_id> --env 3
```

## Complete Workflow

1. Make changes to configuration files in `/root/.config/opencode`
2. Stage all changes:
   ```bash
   cd /root/.config/opencode && git add -A
   ```
3. Commit with descriptive message:
   ```bash
   git commit -m "config: <brief description>"
   ```
4. Push to GitHub:
   ```bash
   git -c credential.helper='!echo "username=git"; echo "password=${GHUB_PAT}"' push
   ```
5. Restart OpenCode container:
   ```bash
   portainerctl container restart opencode --env 3
   ```

## Important Rules

- **MUST** commit immediately after making changes
- **MUST** push changes to GitHub
- **MUST** restart the OpenCode container after pushing
- Use descriptive commit messages with the `config:` prefix
- Always verify changes with `git status` before committing

## Troubleshooting

### Changes not persisting after restart

If configuration changes don't appear to take effect after restart:

1. Verify changes were committed:
   ```bash
   cd /root/.config/opencode && git log --oneline -3
   ```

2. Verify changes were pushed:
   ```bash
   git push --dry-run
   ```

3. Check container logs:
   ```bash
   portainerctl container logs opencode --env 3
   ```

### Container restart fails

If the restart command fails:

```bash
# List all containers
portainerctl container list --env 3

# Get detailed container info
portainerctl container inspect opencode --env 3

# Try force restart
portainerctl container kill opencode --env 3
portainerctl container start opencode --env 3
```

## Best Practices

1. Make small, focused configuration changes
2. Test changes locally before committing
3. Use descriptive commit messages that explain the reason for changes
4. Document significant configuration changes in comments
5. Keep configuration files organized in the appropriate subdirectories
6. Review changes before committing with `git diff`
