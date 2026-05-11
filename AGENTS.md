# OpenCode Global Rules

## Docker & Container Operations

**CRITICAL RULE: The agent MUST NEVER attempt to install, use, or execute Docker locally. Docker is NOT available in the OpenCode environment.**

**For ANY Docker operations (containers, images, networks, volumes, stacks), the agent MUST use the Portainer CLI (`portainer-config-cli`) instead.**

The Portainer CLI is pre-installed globally and automatically configured with credentials from environment variables (`PORTAINER_URL` and `PORTAINER_PAT`).

**Why:** All Docker operations are routed through Portainer CLI, which provides secure, centralized management with authentication and auditability. This is the single source of truth for container infrastructure.

---

## N8N Access

**The agent MUST ALWAYS use the `n8n-cli` (n8n command line interface) for any N8N workflow automation operations.**

The n8n-cli is pre-installed globally and automatically configured with credentials from environment variables in the OpenCode container:
- `N8N_API_URL` - Full URL to the N8N API (e.g. `http://192.168.0.177:5678`)
- `N8N_API_KEY` - API key generated from N8N Settings > API > API Keys

### Available n8n-cli Commands

#### Workflow Management
```bash
n8n workflow list                              # List all workflows
n8n workflow list --format=json                # List workflows in JSON format
n8n workflow export --workflow=<id>            # Export a workflow to JSON
n8n workflow import --file=workflow.json       # Import workflow from JSON file
n8n workflow activate --workflow=<id>          # Activate a workflow
n8n workflow deactivate --workflow=<id>        # Deactivate a workflow
n8n workflow delete --workflow=<id>            # Delete a workflow
n8n workflow execute --workflow=<id>           # Execute a workflow
n8n workflow get --workflow=<id>               # Get workflow details
```

#### Execution Management
```bash
n8n execution list                             # List recent executions
n8n execution list --workflow=<id>             # List executions for a specific workflow
n8n execution get --execution=<id>             # Get execution details
n8n execution delete --execution=<id>          # Delete an execution
n8n execution retry --execution=<id>           # Retry a failed execution
```

#### Credential Management
```bash
n8n credentials list                           # List all credentials
n8n credentials list --format=json             # List credentials in JSON format
n8n credentials export --credential=<id>       # Export a credential
n8n credentials import --file=cred.json        # Import a credential
```

#### Node and Data Management
```bash
n8n node list                                  # List available nodes
n8n node list --format=json                    # List nodes in JSON format
```

### How to use

**List all workflows:**
```bash
n8n workflow list
n8n workflow list --format=json | jq
```

**Get workflow details:**
```bash
n8n workflow get --workflow=abc123
```

**Export a workflow to JSON:**
```bash
n8n workflow export --workflow=abc123 > workflow.json
```

**Import a workflow from JSON:**
```bash
n8n workflow import --file=workflow.json
```

**Activate a workflow:**
```bash
n8n workflow activate --workflow=abc123
```

**Deactivate a workflow:**
```bash
n8n workflow deactivate --workflow=abc123
```

**Execute a workflow:**
```bash
n8n workflow execute --workflow=abc123
```

**List executions for a workflow:**
```bash
n8n execution list --workflow=abc123
```

**Get execution details:**
```bash
n8n execution get --execution=def456
```

**Delete an execution:**
```bash
n8n execution delete --execution=def456
```

**List all available nodes:**
```bash
n8n node list
```

### Important rules
- Always use `n8n` commands through bash/terminal for all N8N operations.
- For JSON output, use `--format=json` and pipe to `jq` for filtering and processing.
- The `N8N_API_URL` and `N8N_API_KEY` environment variables must be set for n8n-cli to connect.
- Use `n8n workflow get --workflow=<id>` to verify workflow details before executing.
- For scripting, prefer JSON output format with `--format=json`.

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
portainerctl container list --env 3          # List containers in environment 3 (local Docker)
portainerctl container list --env 3 --all    # List all containers including stopped
portainerctl container inspect <id> --env 3  # Get detailed container info
portainerctl container logs <id> --env 3     # View container logs
portainerctl container start <id> --env 3    # Start a container
portainerctl container stop <id> --env 3     # Stop a container
portainerctl container restart <id> --env 3  # Restart a container
portainerctl container kill <id> --env 3     # Kill a container
portainerctl container remove <id> --env 3   # Remove a container
portainerctl container stats <id> --env 3    # Get container statistics
```

**Image Management:**
```bash
portainerctl image list --env 3              # List Docker images
portainerctl image list --env 3 -o json      # List images in JSON format
portainerctl image inspect <id> --env 3      # Get image details
portainerctl image pull --env 3 --image nginx:latest  # Pull a Docker image
portainerctl image remove <id> --env 3       # Remove an image
```

**Stack Management:**
```bash
portainerctl stack list                      # List all stacks
portainerctl stack list --env 3              # List stacks in environment 3
portainerctl stack get <id>                  # Get stack details
portainerctl stack file <id>                 # Get stack compose file
portainerctl stack deploy-compose --name myapp --env 3 --file docker-compose.yml  # Deploy stack
portainerctl stack start <id>                # Start a stack
portainerctl stack stop <id>                 # Stop a stack
portainerctl stack redeploy <id>             # Redeploy stack (pull latest from Git)
portainerctl stack delete <id> --env 3       # Delete a stack
```

**Volume Management:**
```bash
portainerctl volume list --env 3             # List volumes
portainerctl volume inspect <name> --env 3   # Get volume details
portainerctl volume create myvolume --env 3  # Create a volume
portainerctl volume remove myvolume --env 3  # Remove a volume
```

**Network Management:**
```bash
portainerctl network list --env 3            # List networks
portainerctl network inspect <id> --env 3    # Get network details
portainerctl network create mynet --env 3 --driver bridge  # Create a network
portainerctl network remove <id> --env 3     # Remove a network
```

### Output Formats

All commands support output formatting:
```bash
portainerctl container list --env 3          # Default: human-readable table
portainerctl container list --env 3 -o json  # JSON output (pipe to jq for filtering)
portainerctl container list --env 3 -o yaml  # YAML output
```

### Usage Examples

**List containers in local Docker environment (env 3):**
```bash
portainerctl container list --env 3
```

**Get container logs with timestamps:**
```bash
portainerctl container logs <container_id> --env 3 --timestamps
```

**Find running container matching a name pattern:**
```bash
portainerctl container list --env 3 -o json | jq '.[] | select(.name | contains("opencode"))'
```

**Restart a specific container by name:**
```bash
portainerctl container restart router-api --env 3
```

**Deploy a Docker Compose stack:**
```bash
portainerctl stack deploy-compose --name myapp --env 3 --file docker-compose.yml
```

**Get stack status:**
```bash
portainerctl stack image-status <stack_id>
```

### Important Rules

- Always use `portainerctl` for all Docker/container operations
- For local Docker operations, use `--env 3` (the local Docker endpoint in this setup)
- Use `-o json` for scripting and data processing with `jq`
- View help for any command: `portainerctl <command> --help`
- API token is automatically configured from `PORTAINER_PAT` environment variable
- Never attempt to use local Docker commands (`docker ps`, `docker run`, etc.) — always use `portainerctl`
- Container names in the JSON output include leading slashes (e.g., `/router-api`)

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
portainerctl container restart opencode --env 3
```

Or to find the container ID and restart by ID:
```bash
portainerctl container list --env 3 -o json | jq '.[] | select(.name | contains("opencode")) | .id'
portainerctl container restart <container_id> --env 3
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

