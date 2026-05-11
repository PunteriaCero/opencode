# OpenCode Global Rules

## Docker & Container Operations

**CRITICAL RULE: The agent MUST NEVER attempt to install, use, or execute Docker locally. Docker is NOT available in the OpenCode environment.**

**For ANY Docker operations (containers, images, networks, volumes, stacks), the agent MUST use the Portainer CLI (`portainer-config-cli`) instead.**

The Portainer CLI is pre-installed globally and automatically configured with credentials from environment variables (`PORTAINER_URL` and `PORTAINER_PAT`).

**Why:** All Docker operations are routed through Portainer CLI, which provides secure, centralized management with authentication and auditability. This is the single source of truth for container infrastructure.

---

## N8N Access

**The agent MUST ALWAYS use the N8N MCP tools for any N8N workflow automation operations.**

The N8N MCP server is connected as a **local MCP endpoint**. The connection is configured via two environment variables in the OpenCode container:
- `N8N_API_URL` - Full URL to the N8N API (e.g. `http://192.168.0.177:5678`)
- `N8N_API_KEY` - API key generated from N8N Settings > API > API Keys

### Available N8N MCP tools

#### Workflow Management
- `n8n_search_workflows` - Search/list workflows (supports `query` and `limit` filters)
- `n8n_get_workflow_details` - Get full details of a workflow by ID
- `n8n_create_workflow` - Create a new workflow with nodes and connections
- `n8n_update_workflow` - Update an existing workflow
- `n8n_delete_workflow` - Delete a workflow
- `n8n_activate_workflow` - Activate a workflow to enable execution
- `n8n_deactivate_workflow` - Deactivate a workflow to disable execution

#### Workflow Execution
- `n8n_execute_workflow` - Execute a workflow with optional input data
- `n8n_list_executions` - List workflow executions with optional filtering (by workflowId, status, limit, offset)
- `n8n_get_execution` - Get details of a specific execution
- `n8n_delete_execution` - Delete an execution record

### How to use

**Search workflows:**
```
n8n_search_workflows(query="keyword", limit=10)
```

**Get workflow details (always do this before executing to understand inputs):**
```
n8n_get_workflow_details(workflowId="abc123")
```

**Create a workflow:**
```
n8n_create_workflow(
  name="My Workflow",
  nodes=[...],
  connections={...},
  active=true,
  tags=["production"]
)
```

**Update a workflow:**
```
n8n_update_workflow(
  workflowId="abc123",
  name="Updated Name",
  active=true
)
```

**Execute a workflow:**
```
n8n_execute_workflow(
  workflowId="abc123",
  inputs={...}
)
```

**List executions:**
```
n8n_list_executions(workflowId="abc123", status="success", limit=20)
```

**Get execution details:**
```
n8n_get_execution(executionId="def456")
```

**Activate/Deactivate workflows:**
```
n8n_activate_workflow(workflowId="abc123")
n8n_deactivate_workflow(workflowId="abc123")
```

### Important rules
- ALWAYS call `n8n_get_workflow_details` before `n8n_execute_workflow` to understand the expected input schema.
- NEVER guess workflow IDs — always search first with `n8n_search_workflows`.
- Use N8N MCP tools instead of direct HTTP calls to the N8N API.
- For workflow creation/updates, ensure nodes and connections are properly structured according to N8N specifications.

## Portainer Access

**The agent MUST ALWAYS use the Portainer CLI (`portainer-config-cli`) for any Docker/Portainer operations.** NEVER use direct curl/bash commands or MCP tools to access Portainer.

The Portainer CLI is pre-installed globally and automatically configured with the `PORTAINER_URL` and `PORTAINER_PAT` environment variables.

### Available Portainer CLI Commands

**Environment & Endpoint Management:**
```bash
portainer-config endpoint list              # List all Docker environments/endpoints
portainer-config endpoint inspect <id>      # Get details of a specific endpoint
```

**Container Management:**
```bash
portainer-config container list [options]   # List containers across endpoints
portainer-config container inspect <id>     # Get detailed container info
portainer-config container start <id>       # Start a stopped container
portainer-config container stop <id>        # Stop a running container
portainer-config container restart <id>     # Restart a container
portainer-config container logs <id>        # View container logs
```

**Image Management:**
```bash
portainer-config image list [options]       # List Docker images
portainer-config image inspect <id>         # Get image details
portainer-config image pull <image>         # Pull a Docker image
portainer-config image delete <id>          # Delete an image
```

**Stack Management:**
```bash
portainer-config stack list                 # List Docker Compose stacks
portainer-config stack inspect <id>         # Get stack details
portainer-config stack deploy <file>        # Deploy a new stack
portainer-config stack remove <id>          # Remove a stack
```

**Network Management:**
```bash
portainer-config network list               # List Docker networks
portainer-config network inspect <id>       # Get network details
```

**Volume Management:**
```bash
portainer-config volume list                # List Docker volumes
portainer-config volume inspect <id>        # Get volume details
```

### Usage Examples

**List all containers in the local environment:**
```bash
portainer-config container list --endpoint 3
```

**Get container logs:**
```bash
portainer-config container logs <container_id>
```

**List all stacks:**
```bash
portainer-config stack list
```

**View help for any command:**
```bash
portainer-config <command> --help
```

### Important Rules

- Always use `portainer-config` for all Docker/container operations
- The CLI is pre-configured with authentication credentials from environment variables
- For complex operations, chain multiple commands using bash pipes and standard text processing tools
- Use `--help` flag on any command for detailed documentation

## GitHub Authentication

The agent MUST use the `GITHUB_PAT` environment variable for all git operations. Configure git to use the PAT token by setting the git credential helper:

```bash
git config --global credential.helper store
echo "https://:${GITHUB_PAT}@github.com" >> ~/.git-credentials
```

Or use the PAT directly in git commands:

```bash
git -c credential.helper='!echo "username=git"; echo "password=${GITHUB_PAT}"' push
```

## Auto-commit on changes

Whenever you modify any file inside `/root/.config/opencode`, you MUST immediately run:

```bash
cd /root/.config/opencode && git add -A && git commit -m "config: <brief description of change>"
```

After committing, you MUST push the changes to GitHub using:

```bash
cd /root/.config/opencode && git -c credential.helper='!echo "username=git"; echo "password=${GITHUB_PAT}"' push
```

## Restart OpenCode after config changes

After successfully pushing changes to GitHub from `/root/.config/opencode`, you MUST restart the OpenCode container via Portainer MCP using the `restart_container` tool with:
- environmentId: 3
- containerId: opencode

## Push changes to GitHub (General Rule)

**CRITICAL: The agent MUST ALWAYS use `git push` with the `GITHUB_PAT` token to upload changes to any repository.**

NEVER use MCP GitHub tools (`github_push_files`, `github_create_or_update_file`, `github_create_pull_request`, etc.) for pushing code changes. ONLY use these tools for read-only operations like listing, searching, or getting information.

For all push operations, use the git CLI with the PAT token:

```bash
git add -A && git commit -m "message" && git -c credential.helper='!echo "username=git"; echo "password=${GITHUB_PAT}"' push
```

Or configure git to use the PAT permanently:

```bash
git config --global user.name "OpenCode Agent"
git config --global user.email "opencode@anomaly.co"
echo "https://:${GITHUB_PAT}@github.com" >> ~/.git-credentials
git config --global credential.helper store
```

Then use standard git commands:

```bash
git add -A && git commit -m "message" && git push
```

