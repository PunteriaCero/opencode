---
name: portainer-cli
description: Use Portainer CLI (portainerctl) for Docker/container operations like managing containers, images, networks, volumes, and stacks. Load this skill whenever the user asks to interact with Docker containers, images, stacks, or any container operations.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: docker
---

# Portainer CLI Skill

## Overview

The Portainer CLI (`portainerctl`) is the official command-line interface for managing Docker containers, images, networks, volumes, and stacks through Portainer. This skill provides comprehensive guidance on using `portainerctl` for all Docker/Portainer operations.

**CRITICAL RULE:** The agent MUST ALWAYS use the `portainerctl` CLI for any Docker/Portainer operations. NEVER use direct curl/bash commands or MCP tools to access Portainer.

## Automatic Configuration

The Portainer CLI is pre-installed globally and automatically configured with credentials from environment variables:

- `PORTAINERCTL_URL=$PORTAINER_URL` - Portainer API URL
- `PORTAINERCTL_TOKEN=$PORTAINER_PAT` - Portainer API token

No manual configuration is required. The environment variables are automatically mapped.

## Environment Information

For local Docker operations, always use `--env 3` (the local Docker endpoint in this setup).

## Available Commands

### Environment Management

```bash
portainerctl env list                        # List all Docker environments
portainerctl env list -o json                # List environments in JSON format
portainerctl env get <id>                    # Get details of a specific environment
portainerctl env snapshot <id>               # Take a snapshot of an environment
```

### Container Management

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

### Image Management

```bash
portainerctl image list --env 3              # List Docker images
portainerctl image list --env 3 -o json      # List images in JSON format
portainerctl image inspect <id> --env 3      # Get image details
portainerctl image pull --env 3 --image nginx:latest  # Pull a Docker image
portainerctl image remove <id> --env 3       # Remove an image
```

### Creating Containers

`portainerctl` **does not have a `container create` or `container run` command**. To create new containers, use **stacks** (Docker Compose):

```bash
# Create a docker-compose.yml file, then deploy it as a stack
portainerctl stack deploy-compose --name myapp --env 3 --file docker-compose.yml
```

This is the only supported way to create containers via `portainerctl`. Define the container configuration in a `docker-compose.yml` file and deploy it as a stack.

### Stack Management

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

### Volume Management

```bash
portainerctl volume list --env 3             # List volumes
portainerctl volume inspect <name> --env 3   # Get volume details
portainerctl volume create myvolume --env 3  # Create a volume
portainerctl volume remove myvolume --env 3  # Remove a volume
```

### Network Management

```bash
portainerctl network list --env 3            # List networks
portainerctl network inspect <id> --env 3    # Get network details
portainerctl network create mynet --env 3 --driver bridge  # Create a network
portainerctl network remove <id> --env 3     # Remove a network
```

## Output Formats

All commands support output formatting:

```bash
portainerctl container list --env 3          # Default: human-readable table
portainerctl container list --env 3 -o json  # JSON output (pipe to jq for filtering)
portainerctl container list --env 3 -o yaml  # YAML output
```

## Usage Examples

### List containers in local Docker environment

```bash
portainerctl container list --env 3
```

### Get container logs with timestamps

```bash
portainerctl container logs <container_id> --env 3 --timestamps
```

### Find running container matching a name pattern

```bash
portainerctl container list --env 3 -o json | jq '.[] | select(.name | contains("opencode"))'
```

### Restart a specific container by name

```bash
portainerctl container restart router-api --env 3
```

### Deploy a Docker Compose stack

```bash
portainerctl stack deploy-compose --name myapp --env 3 --file docker-compose.yml
```

### Get stack status

```bash
portainerctl stack image-status <stack_id>
```

## Important Rules

- `portainerctl` does NOT support `container create` or `container run` — use stacks instead
- Always use `portainerctl` for all Docker/container operations
- For local Docker operations, use `--env 3` (the local Docker endpoint in this setup)
- Use `-o json` for scripting and data processing with `jq`
- View help for any command: `portainerctl <command> --help`
- API token is automatically configured from `PORTAINER_PAT` environment variable
- Never attempt to use local Docker commands (`docker ps`, `docker run`, etc.) — always use `portainerctl`
- Container names in the JSON output include leading slashes (e.g., `/router-api`)

## Troubleshooting

If you encounter authentication errors, verify that environment variables are set:

```bash
echo $PORTAINER_URL
echo $PORTAINER_PAT
```

For more help with specific commands:

```bash
portainerctl <command> --help
```
