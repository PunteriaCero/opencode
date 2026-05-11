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

**The agent MUST ALWAYS use the `portainerctl` CLI for any Docker/Portainer operations.** NEVER use direct curl/bash commands or MCP tools to access Portainer.

The official Portainer CLI (`portainerctl`) is pre-installed globally and automatically configured with the `PORTAINERCTL_URL` and `PORTAINERCTL_TOKEN` environment variables (mapped from `PORTAINER_URL` and `PORTAINER_PAT`).

### Configuration

The environment variables are automatically mapped:
```bash
export PORTAINERCTL_URL=$PORTAINER_URL       # Portainer API URL
export PORTAINERCTL_TOKEN=$PORTAINER_PAT     # Portainer API token
```

### Available Portainer CLI Commands

**Environment Management:**
```bash
portainerctl env list                        # List all Docker environments
portainerctl env list -o json                # List environments in JSON format
portainerctl env get <id>                    # Get details of a specific environment
portainerctl env snapshot <id>               # Take a snapshot of an environment
```

**Container Management:**
```bash
portainerctl container list --env 2          # List containers in environment 2
portainerctl container list --env 2 --all    # List all containers including stopped
portainerctl container inspect <id> --env 2  # Get detailed container info
portainerctl container logs <id> --env 2     # View container logs
portainerctl container start <id> --env 2    # Start a container
portainerctl container stop <id> --env 2     # Stop a container
portainerctl container restart <id> --env 2  # Restart a container
portainerctl container kill <id> --env 2     # Kill a container
portainerctl container remove <id> --env 2   # Remove a container
portainerctl container stats <id> --env 2    # Get container statistics
```

**Image Management:**
```bash
portainerctl image list --env 2              # List Docker images
portainerctl image list --env 2 -o json      # List images in JSON format
portainerctl image inspect <id> --env 2      # Get image details
portainerctl image pull --env 2 --image nginx:latest  # Pull a Docker image
portainerctl image remove <id> --env 2       # Remove an image
```

**Stack Management:**
```bash
portainerctl stack list                      # List all stacks
portainerctl stack list --env 2              # List stacks in environment 2
portainerctl stack get <id>                  # Get stack details
portainerctl stack file <id>                 # Get stack compose file
portainerctl stack deploy-compose --name myapp --env 2 --file docker-compose.yml  # Deploy stack
portainerctl stack start <id>                # Start a stack
portainerctl stack stop <id>                 # Stop a stack
portainerctl stack redeploy <id>             # Redeploy stack (pull latest from Git)
portainerctl stack delete <id> --env 2       # Delete a stack
```

**Volume Management:**
```bash
portainerctl volume list --env 2             # List volumes
portainerctl volume inspect <name> --env 2   # Get volume details
portainerctl volume create myvolume --env 2  # Create a volume
portainerctl volume remove myvolume --env 2  # Remove a volume
```

**Network Management:**
```bash
portainerctl network list --env 2            # List networks
portainerctl network inspect <id> --env 2    # Get network details
portainerctl network create mynet --env 2 --driver bridge  # Create a network
portainerctl network remove <id> --env 2     # Remove a network
```

### Output Formats

All commands support output formatting:
```bash
portainerctl container list --env 2          # Default: human-readable table
portainerctl container list --env 2 -o json  # JSON output (pipe to jq for filtering)
portainerctl container list --env 2 -o yaml  # YAML output
```

### Usage Examples

**List containers in local Docker environment (env 2):**
```bash
portainerctl container list --env 2
```

**Get container logs with timestamps:**
```bash
portainerctl container logs <container_id> --env 2 --timestamps
```

**Find running container matching a name pattern:**
```bash
portainerctl container list --env 2 -o json | jq '.[] | select(.names[] | contains("opencode"))'
```

**Restart a specific container:**
```bash
portainerctl container restart <container_id> --env 2
```

**Deploy a Docker Compose stack:**
```bash
portainerctl stack deploy-compose --name myapp --env 2 --file docker-compose.yml
```

**Get stack status:**
```bash
portainerctl stack image-status <stack_id>
```

### Important Rules

- Always use `portainerctl` for all Docker/container operations
- Provide the `--env <id>` flag to specify the target environment (typically 2 for local Docker)
- Use `-o json` for scripting and data processing with `jq`
- View help for any command: `portainerctl <command> --help`
- API token is automatically configured from `PORTAINER_PAT` environment variable
- Never attempt to use local Docker commands (`docker ps`, `docker run`, etc.) — always use `portainerctl`

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

After successfully pushing changes to GitHub from `/root/.config/opencode`, you MUST restart the OpenCode container via Portainer CLI:

```bash
portainerctl container restart <opencode_container_id> --env 2
```

To find the container ID:
```bash
portainerctl container list --env 2 -o json | jq '.[] | select(.names[] | contains("opencode")) | .id'
```

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

