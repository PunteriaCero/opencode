---
name: n8n-cli
description: Use n8n CLI for N8N workflow automation operations like managing workflows, executions, credentials, and nodes. Load this skill whenever the user asks to interact with N8N workflows, executions, or credentials.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: n8n
---

## What I do

Use `n8n` CLI to interact with N8N workflows and automations directly from the terminal. Always use `n8n` CLI for all N8N operations instead of direct HTTP calls to the N8N API.

## When to use me

Load this skill when the user asks to:
- List, search, or view workflows
- Create, update, delete, or manage workflows
- Activate or deactivate workflows
- Execute workflows
- View, list, or manage workflow executions
- Manage credentials
- List or view available nodes
- Export or import workflows
- Retry failed executions

## Authentication

⚠️ **IMPORTANT: You MUST set N8N_HOST and N8N_API_KEY from environment variables before running any commands.**

### Required Environment Variables

The n8n-cli requires these environment variables to be set:
- `N8N_HOST` - Base URL to the N8N instance (e.g. `http://192.168.0.177:5678`)
- `N8N_API_KEY` - API token for authentication

### Step 1: Extract Environment Variables

**Always check what's available in your environment:**
```bash
env | grep -i n8n
```

This will show you the available N8N variables. Look for:
- `N8N_API_URL` - Contains the host URL
- `N8N_API_KEY` - Contains the authentication token

### Step 2: Export Required Variables

**Before running ANY n8n command, export the variables:**
```bash
# Export N8N_HOST - it's already available in your environment
export N8N_HOST="$N8N_HOST"

# Export N8N_API_KEY - it's already available in your environment  
export N8N_API_KEY="$N8N_API_KEY"

# Verify both are set
echo "N8N_HOST: $N8N_HOST"
echo "N8N_API_KEY: ${N8N_API_KEY:0:20}..."  # Show only first 20 chars for security
```

### Step 3: Verify Connection

```bash
n8n auth status          # Check authentication and connectivity
n8n health              # Verify n8n instance is running
```

### Common Mistakes to Avoid

❌ **WRONG**: Don't use `N8N_API_URL` directly - it includes `/api/v1` path
```bash
# This will fail:
export N8N_HOST="$N8N_API_URL"  # N8N_API_URL includes /api/v1 - Don't do this!
```

✅ **CORRECT**: Use N8N_HOST which already has the correct format
```bash
# N8N_HOST is already set to the correct value: http://192.168.0.177:5678
export N8N_HOST="$N8N_HOST"
export N8N_API_KEY="$N8N_API_KEY"
```

### Connection Troubleshooting

If you get "Unable to connect" errors:
1. Run `env | grep -i n8n` to verify variables exist
2. Verify `N8N_HOST` is just the base URL (no `/api/v1`)
3. Run `n8n auth status` to see the connection details

## Key commands reference

### Workflow Management
```bash
n8n workflows list                              # List all workflows (main command)
n8n workflows get <workflow-id>                 # Get workflow details
n8n workflows export <workflow-id>              # Export workflow to JSON
n8n workflows import --file=workflow.json       # Import workflow from JSON
n8n workflows activate <workflow-id>            # Activate a workflow
n8n workflows deactivate <workflow-id>          # Deactivate a workflow
n8n workflows delete <workflow-id>              # Delete a workflow
n8n workflows execute <workflow-id>             # Execute a workflow
```

### Workflow Execution
```bash
n8n executions list                             # List recent executions
n8n executions list --workflow-id=<id>          # List executions for specific workflow
n8n executions get <execution-id>               # Get execution details
n8n executions delete <execution-id>            # Delete an execution
n8n executions retry <execution-id>             # Retry a failed execution
```

### Credential Management
```bash
n8n credentials list                            # List all credentials
n8n credentials export <credential-id>          # Export a credential
n8n credentials import --file=cred.json         # Import a credential
```

### Node Management
```bash
n8n nodes list                                  # List available nodes
n8n nodes search <search-term>                  # Search for specific nodes
```

### Other utilities
```bash
n8n auth status                                 # Check authentication status and connectivity
n8n health                                      # Check n8n instance health
```

## Common workflows

### ⚠️ PREREQUISITE: Set Environment Variables First

**Before any command below, you MUST export the variables:**
```bash
# Step 1: Check what's available
env | grep -i n8n

# Step 2: Export N8N_HOST and N8N_API_KEY (they are already in your environment)
export N8N_HOST="$N8N_HOST"        # Currently: http://192.168.0.177:5678
export N8N_API_KEY="$N8N_API_KEY"  # Your API token

# Step 3: Verify it works
n8n auth status
```

### Quick start - List all workflows
```bash
# List workflows in table format (requires N8N_HOST and N8N_API_KEY set)
n8n workflows list

# List workflows in JSON format
n8n workflows list --json | jq '.data[] | {id, name, active}'
```

### Get workflow details before executing
```bash
n8n workflows get <workflow-id>
```

### Execute a workflow
```bash
n8n workflows execute <workflow-id>
```

### Export a workflow for backup
```bash
n8n workflows export <workflow-id> > workflow-backup.json
```

### Import a workflow from backup
```bash
n8n workflows import --file=workflow-backup.json
```

### Filter active workflows
```bash
n8n workflows list --json | jq '.data[] | select(.active == true)'
```

### Filter inactive workflows
```bash
n8n workflows list --json | jq '.data[] | select(.active == false)'
```

### Get workflow names only
```bash
n8n workflows list --json | jq -r '.data[] | .name'
```

### Activate multiple workflows
```bash
n8n workflows list --json | jq -r '.data[] | .id' | while read id; do
  n8n workflows activate "$id"
done
```

### List failed executions
```bash
n8n executions list --json | jq '.data[] | select(.status == "failed")'
```

### Get execution details and retry
```bash
n8n executions get <execution-id>
n8n executions retry <execution-id>
```

## Best practices

1. **ALWAYS set environment variables first**: Before running ANY n8n command, ensure `N8N_HOST` and `N8N_API_KEY` are exported
2. **Extract from existing environment**: Run `env | grep -i n8n` to find available credentials
3. **Use correct host format**: `N8N_HOST` should be the base URL. Your current value is `http://192.168.0.177:5678` - use this via `export N8N_HOST="$N8N_HOST"`
4. **Verify connection before proceeding**: Use `n8n auth status` to confirm connectivity
5. **Verify workflow details before executing**: Use `n8n workflows get <id>` to understand inputs and outputs
6. **Use JSON format for scripting**: Use `--json` flag and pipe to `jq` for filtering and processing
7. **Check execution status after running**: List executions with `n8n executions list` to verify success
8. **Export workflows before major changes**: Create backups with `n8n workflows export` before modifying
9. **Never guess workflow IDs**: Always list workflows first with `n8n workflows list` to get accurate IDs
10. **Handle errors gracefully**: Check execution status and use `n8n executions retry` for failed executions

## Output formats

Most commands support:
- Default table format (human-readable) - Shows formatted tables with status indicators
- `--json` flag — output JSON format for programmatic processing
- Pipe to `jq` for filtering and transforming data

### Examples
```bash
# List all workflows in table format
n8n workflows list

# Get workflow details in JSON
n8n workflows list --json | jq '.data[] | {id, name, active, nodes}'

# Filter active workflows only
n8n workflows list --json | jq '.data[] | select(.active == true)'

# Count total workflows
n8n workflows list --json | jq '.data | length'

# Export as CSV-like format
n8n workflows list --json | jq -r '.data[] | "\(.id),\(.name),\(.active)"'

# Format execution data
n8n executions list --json | jq '.data[] | {id, status, startTime, endTime}'
```

## Troubleshooting

### Connection Issues

**Error: "Unable to connect to n8n"**
```bash
# 1. Check if environment variables are set
env | grep -i n8n

# 2. Export the variables (they are already in your environment)
export N8N_HOST="$N8N_HOST"
export N8N_API_KEY="$N8N_API_KEY"

# 3. Verify connection
n8n auth status
n8n health
```

**Connection refused**
- Ensure N8N instance is running
- Verify `N8N_HOST` URL is correct and accessible
- Check firewall rules if N8N is on a different machine

### Authentication Issues

**Authentication error**
```bash
# Verify credentials
n8n auth status

# Check API key in N8N Settings > API > API Keys
# Ensure N8N_API_KEY is set to a valid token
```

### Command Issues

**Workflow not found**: Use full command with `workflows` (plural) not `workflow` (singular)
```bash
n8n workflows list          # Correct
# n8n workflow list         # Incorrect - will fail
```

**JSON parsing errors**
- Use `--json` flag (not `--format=json`)
- Ensure `jq` is installed: `jq --version`
- Verify JSON structure with: `n8n workflows list --json | jq '.'`

### Quick diagnostic command

**If you get connection errors, run this:**
```bash
# Check environment variables are set
env | grep -i n8n

# Export them (they are already in your environment)
export N8N_HOST="$N8N_HOST"
export N8N_API_KEY="$N8N_API_KEY"

# Run all checks at once
n8n auth status && n8n health && n8n workflows list
```

### Complete troubleshooting checklist

1. ✅ Environment variables exist
   ```bash
   env | grep -i n8n
   ```

2. ✅ Export required variables
   ```bash
   export N8N_HOST="$N8N_HOST"
   export N8N_API_KEY="$N8N_API_KEY"
   ```

3. ✅ Verify connection
   ```bash
   n8n auth status
   ```

4. ✅ Check N8N instance is running
   ```bash
   n8n health
   ```

5. ✅ Try listing workflows
   ```bash
   n8n workflows list
   ```

**If step 1 fails**: Environment variables are not set. Ask where to get them.
**If step 3 fails**: `N8N_HOST` or `N8N_API_KEY` is incorrect.
**If step 5 fails**: Connection issue or credentials invalid. Check steps 1-4.
