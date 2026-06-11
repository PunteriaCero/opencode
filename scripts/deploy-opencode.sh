#!/bin/bash
set -e

IMAGE="$1"

if [ -z "$IMAGE" ]; then
  echo "[ERROR] Usage: $0 <image>"
  exit 1
fi

echo "[INFO] Target image: ${IMAGE}"

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
  "${IMAGE}"

echo "[INFO] Deploy complete — '${CONTAINER}' is running with ${IMAGE}"
