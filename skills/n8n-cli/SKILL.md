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

`n8n-cli` is authenticated via environment variables:
- `N8N_HOST` - Base URL to the N8N instance (e.g. `http://192.168.0.177:5678`)
- `N8N_API_KEY` - API key generated from N8N Settings > API > API Keys

If `N8N_HOST` is not set, ensure it's configured:
```bash
export N8N_HOST="http://192.168.0.177:5678"
```

To verify authentication: `n8n health`

## Key commands reference

### Workflow Management
```bash
n8n workflow list                              # List all workflows
n8n workflow list --format=json                # List workflows in JSON format
n8n workflow get --workflow=<id>               # Get workflow details
n8n workflow export --workflow=<id>            # Export workflow to JSON
n8n workflow import --file=workflow.json       # Import workflow from JSON
n8n workflow activate --workflow=<id>          # Activate a workflow
n8n workflow deactivate --workflow=<id>        # Deactivate a workflow
n8n workflow delete --workflow=<id>            # Delete a workflow
n8n workflow execute --workflow=<id>           # Execute a workflow
```

### Workflow Execution
```bash
n8n execution list                             # List recent executions
n8n execution list --workflow=<id>             # List executions for specific workflow
n8n execution list --format=json               # List executions in JSON format
n8n execution get --execution=<id>             # Get execution details
n8n execution delete --execution=<id>          # Delete an execution
n8n execution retry --execution=<id>           # Retry a failed execution
```

### Credential Management
```bash
n8n credentials list                           # List all credentials
n8n credentials list --format=json             # List credentials in JSON format
n8n credentials export --credential=<id>       # Export a credential
n8n credentials import --file=cred.json        # Import a credential
```

### Node Management
```bash
n8n node list                                  # List available nodes
n8n node list --format=json                    # List nodes in JSON format
```

## Common workflows

### List all workflows and filter
```bash
n8n workflow list --format=json | jq '.[] | {id, name, active}'
```

### Get workflow details before executing
```bash
n8n workflow get --workflow=abc123
```

### Execute a workflow
```bash
n8n workflow execute --workflow=abc123
```

### Export a workflow for backup
```bash
n8n workflow export --workflow=abc123 > workflow-backup.json
```

### Import a workflow from backup
```bash
n8n workflow import --file=workflow-backup.json
```

### Activate multiple workflows
```bash
n8n workflow list --format=json | jq -r '.[] | .id' | while read id; do
  n8n workflow activate --workflow=$id
done
```

### List failed executions
```bash
n8n execution list --format=json | jq '.[] | select(.status == "failed")'
```

### Get execution details and retry
```bash
n8n execution get --execution=def456
n8n execution retry --execution=def456
```

### List credentials with sensitive data handling
```bash
n8n credentials list --format=json | jq '.[] | {id, name, type}'
```

## Best practices

1. **Always verify workflow details before executing**: Use `n8n workflow get --workflow=<id>` to understand inputs and outputs.
2. **Use JSON format for scripting**: Use `--format=json` and pipe to `jq` for filtering and processing.
3. **Check execution status after running**: List executions with `n8n execution list --workflow=<id>` to verify success.
4. **Export workflows before major changes**: Create backups with `n8n workflow export` before modifying.
5. **Handle errors gracefully**: Check execution status and use `n8n execution retry` for failed executions.
6. **Use proper JSON filtering**: Combine `--format=json` with `jq` for precise data extraction.
7. **Never guess workflow IDs**: Always list workflows first to get accurate IDs.
8. **Keep credentials secure**: Export credentials only when necessary, use credential IDs carefully.

## Output formats

Most commands support:
- Default table format (human-readable)
- `--format=json` — output JSON format
- Pipe to `jq` for filtering: `n8n workflow list --format=json | jq`

### Examples
```bash
# Get workflow names only
n8n workflow list --format=json | jq -r '.[] | .name'

# Filter active workflows
n8n workflow list --format=json | jq '.[] | select(.active == true)'

# Count total workflows
n8n workflow list --format=json | jq 'length'

# Format execution data
n8n execution list --format=json | jq '.[] | {id, status, startTime, endTime}'
```

## Troubleshooting

**Authentication error**: Verify `N8N_API_URL` and `N8N_API_KEY` environment variables are set correctly.

**Workflow not found**: Use `n8n workflow list` to get the exact workflow ID.

**Execution failed**: Check execution details with `n8n execution get --execution=<id>` and retry with `n8n execution retry --execution=<id>`.

**JSON parsing errors**: Ensure you're using `--format=json` flag and proper `jq` syntax for filtering.
