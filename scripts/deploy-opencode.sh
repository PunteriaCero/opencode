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

# Volume mounts: -v source:destination
VOLUME_ARGS=$(docker inspect "${CONTAINER}" \
  --format '{{range .Mounts}}-v {{.Source}}:{{.Destination}} {{end}}')

echo "[INFO] Restart policy : ${RESTART}"
echo "[INFO] Network        : ${NETWORK}"
echo "[INFO] Ports          : ${PORT_ARGS}"
echo "[INFO] Volumes        : ${VOLUME_ARGS}"

# --- Pull new image ---
echo "[INFO] Pulling ${IMAGE}..."
docker pull "${IMAGE}"

# --- Recreate container ---
echo "[INFO] Stopping and removing '${CONTAINER}'..."
docker stop "${CONTAINER}"
docker rm "${CONTAINER}"

echo "[INFO] Starting new container..."
# shellcheck disable=SC2086
docker run -d \
  --name "${CONTAINER}" \
  --restart "${RESTART}" \
  --network "${NETWORK}" \
  ${PORT_ARGS} \
  ${VOLUME_ARGS} \
  --env-file "$ENV_FILE" \
  "${IMAGE}"

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
echo "║  Next Steps:                                                       ║"
echo "║  1. Open http://localhost:4096 in your browser                    ║"
echo "║  2. Configure MCP servers in opencode.json if needed              ║"
echo "║  3. Check server logs: docker logs ${CONTAINER}                   ║"
echo "║  4. Monitor performance: docker stats ${CONTAINER}                ║"
echo "║                                                                    ║"
echo "║  To stop:   docker stop ${CONTAINER}                              ║"
echo "║  To remove: docker rm ${CONTAINER}                                ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
