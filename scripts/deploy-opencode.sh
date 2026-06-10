#!/bin/bash
set -e

IMAGE="$1"
CONTAINER_NAME="opencode"

if [ -z "$IMAGE" ]; then
  echo "[ERROR] Usage: $0 <image>"
  exit 1
fi

echo "[INFO] Pulling image: ${IMAGE}"
docker pull "${IMAGE}"

# --- Find compose file ---
# 1st: use Docker label (most reliable)
COMPOSE_FILE=$(docker inspect "${CONTAINER_NAME}" \
  --format '{{index .Config.Labels "com.docker.compose.project.config_files"}}' 2>/dev/null || true)

# 2nd: search known CasaOS paths
if [ -z "$COMPOSE_FILE" ] || [ ! -f "$COMPOSE_FILE" ]; then
  echo "[INFO] Label not found, searching for compose file..."
  COMPOSE_FILE=$(find /var/lib/casaos /DATA 2>/dev/null \
    -name "docker-compose.yml" \
    | xargs grep -l "opencode" 2>/dev/null \
    | head -1 || true)
fi

if [ -z "$COMPOSE_FILE" ] || [ ! -f "$COMPOSE_FILE" ]; then
  echo "[ERROR] Could not find docker-compose.yml for '${CONTAINER_NAME}'"
  echo "[INFO] Searched Docker labels and /var/lib/casaos, /DATA"
  exit 1
fi

echo "[INFO] Compose file: ${COMPOSE_FILE}"
COMPOSE_DIR=$(dirname "${COMPOSE_FILE}")

# Update image reference in compose file
sed -i "s|image: ghcr\.io/.*|image: ${IMAGE}|" "${COMPOSE_FILE}"
echo "[INFO] Updated image to: ${IMAGE}"
grep "image:" "${COMPOSE_FILE}"

# Recreate container
cd "${COMPOSE_DIR}"
docker compose up -d --force-recreate

echo "[INFO] Deploy complete"
