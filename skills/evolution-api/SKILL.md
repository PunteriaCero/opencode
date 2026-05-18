---
name: evolution-api
description: Integrate with Evolution API for WhatsApp messaging automation. Reads API URL, authentication key, and instance ID from environment variables EVOLUTION_API_URL, EVOLUTION_API_KEY, and EVOLUTION_API_INSTANCE.
license: MIT
compatibility: opencode
metadata:
  category: messaging
  api: evolution-api
---

## What I do

- Provide integration functions for Evolution API (WhatsApp messaging platform)
- Automatically read API credentials from environment variables
- Handle authentication and API requests
- Support WhatsApp messaging operations

## When to use me

Load this skill whenever you need to:
- Send WhatsApp messages via Evolution API
- Manage WhatsApp accounts and instances
- Interact with Evolution API endpoints
- Build WhatsApp automation workflows

## Setup

Ensure the following environment variables are configured:

```bash
export EVOLUTION_API_URL="https://your-evolution-api-url.com"
export EVOLUTION_API_KEY="your-api-key-here"
export EVOLUTION_API_INSTANCE="784F3B7A0529-4E4D-AEFC-1178ED9D85A2"
```

### Instance ID Format

The `EVOLUTION_API_INSTANCE` variable should contain a unique WhatsApp instance identifier in UUID format (e.g., `784F3B7A0529-4E4D-AEFC-1178ED9D85A2`). This identifier is automatically assigned by Evolution API when creating a new instance.

## Available Functions

### Verifying Environment Variables

Before making API calls, verify that the required environment variables are set:

```bash
# Check if EVOLUTION_API_URL is set (returns character count)
echo "${#EVOLUTION_API_URL} characters loaded"

# Check if EVOLUTION_API_KEY is set (returns character count)
echo "${#EVOLUTION_API_KEY} characters loaded"

# Check if EVOLUTION_API_INSTANCE is set (returns character count)
echo "${#EVOLUTION_API_INSTANCE} characters loaded"
```

### Making API Requests

Use `curl` with environment variables for authentication:

```bash
# Example: Get Evolution API status
curl -X GET \
  "${EVOLUTION_API_URL}/status" \
  -H "Authorization: Bearer ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json"
```

### Common Endpoints

**Get Instance Status**
```bash
curl -X GET \
  "${EVOLUTION_API_URL}/instance/${EVOLUTION_API_INSTANCE}" \
  -H "Authorization: Bearer ${EVOLUTION_API_KEY}"
```

**Send Message**
```bash
curl -X POST \
  "${EVOLUTION_API_URL}/message/sendText/${EVOLUTION_API_INSTANCE}" \
  -H "Authorization: Bearer ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "number": "recipient_number",
    "text": "message_text"
  }'
```

**Send Media**
```bash
curl -X POST \
  "${EVOLUTION_API_URL}/message/sendMedia/${EVOLUTION_API_INSTANCE}" \
  -H "Authorization: Bearer ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "number": "recipient_number",
    "mediaUrl": "https://example.com/image.jpg",
    "caption": "optional_caption"
  }'
```

## Authentication Pattern

**IMPORTANT SECURITY RULE:** Never print or expose the API credentials in logs or terminal output.

Always reference environment variables directly in API calls:

```bash
# Correct: credentials are not exposed
curl -H "Authorization: Bearer ${EVOLUTION_API_KEY}" "${EVOLUTION_API_URL}/endpoint"

# Incorrect: exposes credentials in terminal
echo "URL: ${EVOLUTION_API_URL}"
echo "Key: ${EVOLUTION_API_KEY}"
```

## Error Handling

Common HTTP status codes:
- `200`: Success
- `400`: Bad request (check payload)
- `401`: Unauthorized (verify API key)
- `404`: Resource not found
- `429`: Rate limited
- `500`: Server error

## Base URL Examples

Common Evolution API deployment URLs:
- `https://api.evolution.ai`
- `https://evolution.yourdomain.com`
- `http://localhost:8080` (local development)

## Additional Resources

- [Evolution API Documentation](https://evolution-api.readme.io/)
- [Evolution API GitHub](https://github.com/EvolutionAPI/evolution-api)

