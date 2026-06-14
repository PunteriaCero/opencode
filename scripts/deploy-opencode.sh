#!/bin/bash
set -e

IMAGE="$1"

if [ -z "$IMAGE" ]; then
  echo "[ERROR] Usage: $0 <image>"
  exit 1
fi

echo "[INFO] Target image: ${IMAGE}"

# ═══════════════════════════════════════════════════════════════════════════
# OPENCODE WEB SERVER DEPLOYMENT
# ═══════════════════════════════════════════════════════════════════════════
# OpenCode is a VS Code agent running in a Docker container as a web server.
#
# Server Command:
# - Command: opencode serve
# - Hostname: 0.0.0.0 (listen on all interfaces for remote access)
# - Port: 4096 (default HTTP endpoint)
#
# Deployment Details:
# - Web Server Port: 4096 (default HTTP endpoint)
# - Access URL: http://localhost:4096 or http://your-host:4096
# - Health Check: HTTP GET to / (expects 200, 301, or 302 status)
# - Persistence: Data stored in Docker volumes
# - SSH Keys: Persistent volume at /root/.ssh (for git operations)
# - Restart Policy: unless-stopped (auto-restart on failure)
#
# MCP Servers (enabled/disabled in opencode.json):
# - GitHub: For repository operations (requires GHUB_PAT token)
# - Google Drive: For file management (requires GDRIVE credentials)
# - Home Assistant: For smart home automation (remote connection)
# - N8N: For workflow automation (requires N8N connection details)
#
# Optional Authentication:
# - Set OPENCODE_SERVER_USERNAME environment variable (default: 'opencode')
# - Set OPENCODE_SERVER_PASSWORD environment variable for HTTP Basic Auth
# - If no password is set, server will warn about being unprotected
#
# The container runs as a background service with network access to expose
# the web interface for local or remote access.
# ═══════════════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════════════
# ENVIRONMENT VARIABLES INJECTION (Option B: .env file)
# ═══════════════════════════════════════════════════════════════════════════
# This script captures environment variables passed from GitHub Actions and
# creates a temporary .env file to be injected into the Docker container.
#
# Variables available:
# - From GitHub Actions "env:" section in workflow
# - From GitHub secrets (${{ secrets.VAR_NAME }})
# - From GitHub variables (${{ vars.VAR_NAME }})
#
# The .env file will be read by docker run using --env-file flag
# ═══════════════════════════════════════════════════════════════════════════

# Create .env file with environment variables to inject into container
# Filter out system/internal variables (GITHUB_*, RUNNER_*, PATH, HOME, etc.)
ENV_FILE=".env.opencode"

echo "[INFO] Creating environment file for container injection..."

# Build the .env file - capture only relevant application variables
# This approach filters out GitHub Actions internal variables and system vars
{
  # List all environment variables, filter out system ones
  env | while IFS='=' read -r key value; do
    # Skip GitHub Actions internal variables
    [[ "$key" == GITHUB_* ]] && continue
    [[ "$key" == RUNNER_* ]] && continue
    [[ "$key" == ACTIONS_* ]] && continue
    
    # Skip standard system variables
    [[ "$key" == "PATH" ]] && continue
    [[ "$key" == "HOME" ]] && continue
    [[ "$key" == "SHELL" ]] && continue
    [[ "$key" == "USER" ]] && continue
    [[ "$key" == "LOGNAME" ]] && continue
    [[ "$key" == "PWD" ]] && continue
    [[ "$key" == "LANG" ]] && continue
    [[ "$key" == "LC_"* ]] && continue
    
    # Skip Docker-related system variables
    [[ "$key" == "DOCKER_"* ]] && continue
    [[ "$key" == "REGISTRY_OWNER_LOWER" ]] && continue
    
    # Export the variable to .env (preserving quotes for complex values)
    echo "${key}=${value}"
  done
} > "$ENV_FILE" || true

if [ -s "$ENV_FILE" ]; then
  echo "[INFO] Environment variables to inject:"
  grep -v "^$" "$ENV_FILE" | while IFS='=' read -r key value; do
    # Show variable name but mask value for sensitive vars
    if [[ "$key" == *"SECRET"* ]] || [[ "$key" == *"PASSWORD"* ]] || [[ "$key" == *"TOKEN"* ]] || [[ "$key" == *"KEY"* ]]; then
      echo "  ✓ $key=***MASKED***"
    else
      echo "  ✓ $key=$value"
    fi
  done
  echo "[INFO] Environment file created: $ENV_FILE"
else
  echo "[INFO] No additional environment variables to inject"
fi

# --- Find the container (try common name variants) ---
CONTAINER=""
for name in opencode opencode_fix opencode-fix; do
  if docker inspect "${name}" > /dev/null 2>&1; then
    CONTAINER="${name}"
    break
  fi
done

if [ -z "${CONTAINER}" ]; then
  # Last resort: find by image name
  CONTAINER=$(docker ps --format '{{.Names}}' | grep -i opencode | head -1 || true)
fi

if [ -z "${CONTAINER}" ]; then
  echo "[ERROR] Could not find OpenCode container"
  echo "[DEBUG] All running containers:"
  docker ps --format 'table {{.Names}}\t{{.Image}}'
  exit 1
fi

echo "[INFO] Found container: ${CONTAINER}"

# --- Extract current container config via docker inspect ---
RESTART=$(docker inspect "${CONTAINER}" --format '{{.HostConfig.RestartPolicy.Name}}')
NETWORK=$(docker inspect "${CONTAINER}" --format '{{.HostConfig.NetworkMode}}')

# Port mappings: "4096/tcp -> 0.0.0.0:4096" => -p 4096:4096
PORT_ARGS=""
while IFS= read -r line; do
  [ -z "$line" ] && continue
  container_port=$(echo "$line" | awk -F'/' '{print $1}')
  host_port=$(echo "$line" | awk -F':' '{print $NF}')
  PORT_ARGS="${PORT_ARGS} -p ${host_port}:${container_port}"
done < <(docker port "${CONTAINER}" 2>/dev/null || true)

# Volume mounts: Extract named volumes and bind mounts
# Named volumes format: -v volume_name:/path/in/container
# Bind mounts format: -v /host/path:/container/path
VOLUME_ARGS=$(docker inspect "${CONTAINER}" \
  --format '{{range .Mounts}}{{if eq .Type "volume"}}-v {{.Name}}:{{.Destination}} {{else}}-v {{.Source}}:{{.Destination}} {{end}}{{end}}')

echo "[INFO] Restart policy : ${RESTART}"
echo "[INFO] Network        : ${NETWORK}"
echo "[INFO] Ports          : ${PORT_ARGS}"
echo "[INFO] Volumes        : ${VOLUME_ARGS}"

# Validate that we have persistent volumes configured
if [[ ! "$VOLUME_ARGS" =~ opencode_data ]]; then
  echo "[WARNING] Named volume 'opencode_data' not found in container configuration"
fi

if [[ ! "$VOLUME_ARGS" =~ opencode_ssh ]]; then
  echo "[WARNING] Named volume 'opencode_ssh' not found in container configuration"
fi

# --- Pull new image ---
echo "[INFO] Pulling ${IMAGE}..."
docker pull "${IMAGE}"

# --- Update docker-compose.yml with new image ---
# Create temporary docker-compose override to use the new image
COMPOSE_OVERRIDE="docker-compose.override.yml"

echo "[INFO] Creating temporary docker-compose override with new image..."
cat > "$COMPOSE_OVERRIDE" << EOF
version: '3.8'
services:
  opencode:
    image: ${IMAGE}
EOF

# --- Recreate container using docker-compose ---
echo "[INFO] Stopping and recreating '${CONTAINER}'..."
docker-compose down --remove-orphans || true

echo "[INFO] Starting new container with docker-compose..."
# Use --env-file to inject variables into docker-compose
docker-compose --env-file "$ENV_FILE" up -d

# Clean up override
rm -f "$COMPOSE_OVERRIDE"

echo "[INFO] Deploy complete — '${CONTAINER}' is running with ${IMAGE}"

# ═══════════════════════════════════════════════════════════════════════════
# CLEANUP: Remove temporary .env file
# ═══════════════════════════════════════════════════════════════════════════
# The .env file is no longer needed after container creation.
# Docker has already injected the variables into the container.
# Removing it reduces security risk of leaving secrets on disk.
# ═══════════════════════════════════════════════════════════════════════════

if [ -f "$ENV_FILE" ]; then
  rm -f "$ENV_FILE"
  echo "[INFO] Temporary environment file cleaned up"
fi

# ═══════════════════════════════════════════════════════════════════════════
# DEPLOYMENT SUMMARY
# ═══════════════════════════════════════════════════════════════════════════

echo ""
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║  OpenCode Web Server Deployment Summary                           ║"
echo "╠════════════════════════════════════════════════════════════════════╣"
echo "║  Container: ${CONTAINER}"
echo "║  Image:     ${IMAGE}"
echo "║  Status:    Running on port 4096"
echo "║  Access:    http://localhost:4096"
echo "║                                                                    ║"
echo "║  Persistent Volumes:                                              ║"
echo "║  • opencode_data: Application data & configuration                ║"
echo "║  • opencode_ssh: SSH keys for Git authentication                  ║"
echo "║                                                                    ║"
echo "║  SSH Configuration:                                                ║"
echo "║  • SSH keys are preserved across container restarts               ║"
echo "║  • Add GitHub keys to ~/.ssh for git push operations              ║"
echo "║  • Location in container: ~/.ssh (persistent volume)              ║"
echo "║                                                                    ║"
echo "║  Next Steps:                                                       ║"
echo "║  1. Open http://localhost:4096 in your browser                    ║"
echo "║  2. Configure MCP servers in opencode.json if needed              ║"
echo "║  3. Add SSH keys for GitHub: https://github.com/settings/keys     ║"
echo "║  4. Check server logs: docker logs ${CONTAINER}                   ║"
echo "║  5. Monitor performance: docker stats ${CONTAINER}                ║"
echo "║                                                                    ║"
echo "║  To manage:                                                        ║"
echo "║  • Stop:  docker-compose down                                      ║"
echo "║  • Start: docker-compose up -d                                     ║"
echo "║  • Logs:  docker-compose logs -f                                   ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
