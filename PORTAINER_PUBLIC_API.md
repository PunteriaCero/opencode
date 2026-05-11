# Portainer Public API - OpenCode Integration

## Overview

La configuración global de OpenCode ahora incluye acceso a los nuevos endpoints públicos del servidor Portainer MCP que permiten:

1. Listar imágenes Docker sin autenticación
2. Identificar imágenes sin uso
3. Limpiar automáticamente imágenes dangling

## Configuración

La configuración se realiza automáticamente en `opencode.json`:

```json
{
  "portainer": {
    "type": "local",
    "command": ["npx", "-y", "portainer-mcp-server"],
    "enabled": true,
    "environment": {
      "PORTAINER_URL": "{env:PORTAINER_URL}",
      "PORTAINER_PAT": "{env:PORTAINER_PAT}",
      "PUBLIC_PORT": "3000"
    }
  }
}
```

## Variables de Entorno

Asegúrate de que estas variables estén configuradas en tu entorno:

- `PORTAINER_URL` - URL del servidor Portainer (se obtiene de la variable de entorno `$PORTAINER_URL`)
- `PORTAINER_PAT` - API Key/Token de Portainer (requerido)
- `PUBLIC_PORT` - Puerto para la API pública (default: `3000`)

## Uso desde OpenCode

### Usando los endpoints directamente

Puedes hacer peticiones HTTP directas a los endpoints públicos:

```bash
# Listar todas las imágenes
curl http://localhost:3000/api/images?environmentId=1

# Listar imágenes sin uso
curl http://localhost:3000/api/images/unused?environmentId=1

# Limpiar imágenes sin uso
curl -X POST http://localhost:3000/api/images/cleanup?environmentId=1
```

### Desde scripts OpenCode

Puedes integrar estos endpoints en tus workflows automáticos:

```javascript
// Ejemplo: Obtener imágenes sin uso
const response = await fetch('http://localhost:3000/api/images/unused?environmentId=1');
const data = await response.json();
console.log(`Found ${data.count} unused images`);

// Ejemplo: Limpiar imágenes
const cleanupResponse = await fetch('http://localhost:3000/api/images/cleanup', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' }
});
const cleanupData = await cleanupResponse.json();
console.log(`Deleted ${cleanupData.deletedCount} images`);
```

## Endpoints Disponibles

### GET /api/images

Lista todas las imágenes Docker disponibles.

**Request:**
```bash
curl "http://localhost:3000/api/images?environmentId=1"
```

**Response:**
```json
{
  "success": true,
  "count": 5,
  "images": [
    {
      "id": "sha256:abc123",
      "tags": ["nginx:latest"],
      "size": "142.5MB",
      "created": 1234567890,
      "repoDigests": ["nginx@sha256:..."]
    }
  ]
}
```

---

### GET /api/images/unused

Lista imágenes que no son utilizadas por ningún contenedor.

**Request:**
```bash
curl "http://localhost:3000/api/images/unused?environmentId=1"
```

**Response:**
```json
{
  "success": true,
  "count": 2,
  "unusedImages": [
    {
      "id": "sha256:def456",
      "fullId": "sha256:def456789...",
      "tags": ["<none>"],
      "size": "5.2MB",
      "created": 1234567890,
      "dangling": true
    }
  ]
}
```

---

### POST /api/images/cleanup

Elimina todas las imágenes sin uso.

**Request:**
```bash
curl -X POST "http://localhost:3000/api/images/cleanup?environmentId=1&force=false"
```

**Response:**
```json
{
  "success": true,
  "message": "Cleanup completed. Deleted 2 image(s).",
  "deletedCount": 2,
  "failedCount": 0,
  "deleted": [
    {
      "id": "sha256:def456",
      "tags": ["<none>"],
      "size": "5.2MB"
    }
  ]
}
```

## Casos de Uso

### 1. Monitoreo automático de imágenes dangling

Crea un workflow que periódicamente verifique imágenes sin uso:

```bash
# Verificar cada hora
curl -s "http://localhost:3000/api/images/unused?environmentId=1" | \
  jq '.count' | \
  mail -s "Docker Images Cleanup Report" admin@example.com
```

### 2. CI/CD Integration

Integra la limpieza en tu pipeline de CI/CD:

```bash
# En tu workflow de GitHub Actions o Jenkins
curl -X POST "http://localhost:3000/api/images/cleanup?environmentId=1&force=false"
```

### 3. Alertas de espacio en disco

Monitorea el tamaño total de imágenes sin uso:

```bash
curl -s "http://localhost:3000/api/images/unused?environmentId=1" | \
  jq '[.unusedImages[].size | gsub("MB"; "") | tonumber] | add'
```

## Notas de Seguridad

⚠️ **Importante**: Estos endpoints son públicos sin autenticación. Se recomienda:

1. **Protección con Firewall**: Limita el acceso a IPs confiables
2. **Proxy Reverso**: Usa nginx/Caddy para añadir autenticación
3. **Rate Limiting**: Implementa límites de tasa de peticiones
4. **Red Privada**: Usa en redes internas, no expongas en internet

Ejemplo de protección con nginx:

```nginx
location /api/images {
  # Solo localhost
  allow 127.0.0.1;
  allow ::1;
  deny all;
  
  proxy_pass http://localhost:3000;
}
```

## Troubleshooting

### "Connection refused"

Verifica que el servidor Portainer MCP esté corriendo:

```bash
ps aux | grep portainer-mcp
```

Si no está corriendo, reinicia el contenedor:

```bash
docker restart <portainer-mcp-container>
```

### "Cannot connect to Portainer"

Verifica las variables de entorno:

```bash
echo $PORTAINER_URL
echo $PORTAINER_PAT
```

Asegúrate de que `PORTAINER_PAT` sea un token válido de Portainer.

### No se eliminan imágenes

Las imágenes se consideren "sin uso" si:

1. No son usadas por NINGÚN contenedor (activo o detenido)
2. Son imágenes dangling (sin tags) O tienen solo tags `<none>`

Verifica esto con:

```bash
curl "http://localhost:3000/api/images/unused?environmentId=1"
```

---

## Documentación Completa

Para más información, consulta:

- [PUBLIC_API.md](../portainer-mcp-server/PUBLIC_API.md) - Documentación técnica completa
- [AGENTS.md](./AGENTS.md) - Guía global de OpenCode
