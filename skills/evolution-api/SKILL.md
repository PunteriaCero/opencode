---
name: evolution-api
description: Integrate with Evolution API v2 for WhatsApp messaging automation. Reads API URL, authentication key, and instance ID from environment variables EVOLUTION_API_URL, EVOLUTION_API_KEY, and EVOLUTION_API_INSTANCE.
license: MIT
compatibility: opencode
metadata:
  category: messaging
  api: evolution-api
  version: "2.2.3"
---

## What I do

- Provide integration with Evolution API v2 (WhatsApp messaging and automation platform)
- Automatically read API credentials from environment variables
- Support all major Evolution API endpoints: messaging, chat management, instance control, and integrations
- Handle authentication securely and manage API requests
- Support WhatsApp messaging, groups, media, and advanced features

## When to use me

Load this skill whenever you need to:
- Send WhatsApp messages (text, media, buttons, locations, contacts)
- Read and manage chats and messages
- Create and manage WhatsApp groups
- Connect/disconnect WhatsApp instances
- Integrate with Typebot, Chatwoot, Dify, OpenAI, or other platforms
- Build WhatsApp automation workflows and bots

## Setup

Ensure the following environment variables are configured:

```bash
export EVOLUTION_API_URL="https://your-evolution-api-url.com"
export EVOLUTION_API_KEY="your-api-key-here"
export EVOLUTION_API_INSTANCE="instance-name-or-uuid"
```

### Instance Format

The `EVOLUTION_API_INSTANCE` variable contains the WhatsApp instance identifier. This can be:
- A UUID format (e.g., `784F3B7A0529-4E4D-AEFC-1178ED9D85A2`)
- An instance name (e.g., `whatsapp-bot-001`)
- Any identifier assigned by Evolution API when creating the instance

### Verifying Environment Variables

Before making API calls, verify that the required environment variables are set:

```bash
# Check if variables are loaded (safe - returns character count only)
echo "${#EVOLUTION_API_URL} characters loaded"
echo "${#EVOLUTION_API_KEY} characters loaded"
echo "${#EVOLUTION_API_INSTANCE} characters loaded"
```

## Authentication

Evolution API uses **API Key authentication** in request headers:

```bash
# Correct: API key is passed in header (not exposed)
curl -H "apikey: ${EVOLUTION_API_KEY}" "${EVOLUTION_API_URL}/endpoint"

# Incorrect: never expose the API key in terminal
echo "Key: ${EVOLUTION_API_KEY}"
```

## Main Endpoints

### 1. Get API Information

**Endpoint:** `GET /`

Returns general information about the Evolution API instance.

```bash
curl -X GET \
  "${EVOLUTION_API_URL}/" \
  -H "Content-Type: application/json"
```

**Response (200 OK):**
```json
{
  "status": 200,
  "message": "Welcome to the Evolution API, it is working!",
  "version": "2.2.3",
  "manager": "http://localhost:8084/manager",
  "documentation": "https://doc.evolution-api.com"
}
```

---

### 2. Instance Management

#### Get Instance Connection State

**Endpoint:** `GET /instance/connectionState/{instance}`

Get the current connection state of an instance.

```bash
curl -X GET \
  "${EVOLUTION_API_URL}/instance/connectionState/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}"
```

**Response (200 OK):**
```json
{
  "instance": {
    "instanceName": "whatsapp-bot-001",
    "state": "open"
  }
}
```

**States:** `open`, `closed`, `connecting`, `loading`

#### Generate QR Code (Connect Instance)

**Endpoint:** `GET /instance/connect/{instance}`

Generate QR code to connect a WhatsApp instance.

```bash
curl -X GET \
  "${EVOLUTION_API_URL}/instance/connect/${EVOLUTION_API_INSTANCE}?number=5491165002220" \
  -H "apikey: ${EVOLUTION_API_KEY}"
```

**Response (200 OK):**
```json
{
  "pairingCode": "WZYEH1YY",
  "code": "2@y8eK+bjtEjUWy9/FOM...",
  "count": 1
}
```

---

### 3. Find and Read Chats

#### List All Chats

**Endpoint:** `POST /chat/findChats/{instance}`

Retrieve all chats for the instance.

```bash
curl -X POST \
  "${EVOLUTION_API_URL}/chat/findChats/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json"
```

**Response (200 OK):** Returns array of chat objects with message history.

#### Find Messages in a Chat

**Endpoint:** `POST /chat/findMessages/{instance}`

Retrieve messages from a specific chat, with optional filtering and pagination.

```bash
# Get latest 5 messages from a chat
curl -X POST \
  "${EVOLUTION_API_URL}/chat/findMessages/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "chatId": "5491165002220@s.whatsapp.net",
    "limit": 5
  }'

# Alternative: Get messages with advanced filtering
curl -X POST \
  "${EVOLUTION_API_URL}/chat/findMessages/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "where": {
      "key": {
        "remoteJid": "5491165002220@s.whatsapp.net"
      }
    }
  }'
```

**Query Parameters:**
- `chatId`: Filter messages by chat ID (individual or group)
- `limit`: Maximum number of messages to return
- `where`: Advanced filtering object (alternative to simple parameters)

**Chat ID Formats:**
- **Individual chats:** `PHONENUMBER@s.whatsapp.net` (e.g., `5491165002220@s.whatsapp.net`)
- **Group chats:** `GROUPID@g.us` (e.g., `120363012345678900@g.us`)

**Message Object Structure:**
```json
{
  "id": "message-database-id",
  "key": {
    "id": "BAE594145F4C59B4",
    "fromMe": false,
    "remoteJid": "5491165002220@s.whatsapp.net"
  },
  "pushName": "Contact Name",
  "messageType": "conversation",
  "message": {
    "conversation": "Message text content"
  },
  "messageTimestamp": 1778000210,
  "source": "android",
  "MessageUpdate": [{"status": "READ"}]
}
```

**Message Types:**
- `conversation`: Plain text messages
- `imageMessage`: Image with optional caption
- `videoMessage`: Video content
- `audioMessage`: Audio/voice note (PTT for push-to-talk)
- `documentMessage`: File attachments
- `stickerMessage`: WhatsApp stickers
- `reactionMessage`: Emoji reactions
- `pinInChatMessage`: Pinned message notifications
- `buttonMessage`: Interactive buttons
- `listMessage`: List/menu selections

**Response (200 OK):** Returns array of message objects with metadata.

---

### 4. Send Messages

#### Send Plain Text Message

**Endpoint:** `POST /message/sendText/{instance}`

Send a simple text message.

```bash
curl -X POST \
  "${EVOLUTION_API_URL}/message/sendText/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "number": "5491165002220",
    "text": "Hello! This is a test message",
    "delay": 1000,
    "linkPreview": true
  }'
```

**Payload Fields:**
- `number` (required): Phone number with country code (e.g., `5491165002220`)
- `text` (required): Message text
- `delay` (optional): Milliseconds to wait before sending
- `linkPreview` (optional): Show link preview (default: true)
- `mentioned` (optional): Array of phone numbers to mention
- `mentionsEveryOne` (optional): Mention all (groups only)
- `quoted` (optional): Reply to a message

**Response (201 Created):** Returns message key and status.

#### Send Media Message

**Endpoint:** `POST /message/sendMedia/{instance}`

Send image, video, audio, or document.

```bash
curl -X POST \
  "${EVOLUTION_API_URL}/message/sendMedia/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "number": "5491165002220",
    "mediaUrl": "https://example.com/image.jpg",
    "caption": "Check this image!"
  }'
```

**Payload Fields:**
- `number` (required): Recipient phone number
- `mediaUrl` (required): URL to the media file
- `caption` (optional): Caption for the media
- `media` (alternative): Base64-encoded media instead of URL
- `fileName` (optional): Filename for documents

**Supported Media Types:**
- Images: JPG, PNG, GIF
- Videos: MP4, WebM
- Audio: MP3, OGG, WAV
- Documents: PDF, DOC, DOCX, XLS, XLSX, etc.

#### Send Buttons

**Endpoint:** `POST /message/sendButton/{instance}`

Send interactive button message.

```bash
curl -X POST \
  "${EVOLUTION_API_URL}/message/sendButton/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "number": "5491165002220",
    "title": "Choose an option",
    "description": "Select one of the buttons below",
    "buttons": [
      {
        "buttonId": "1",
        "buttonText": "Option 1"
      },
      {
        "buttonId": "2",
        "buttonText": "Option 2"
      }
    ]
  }'
```

#### Send Location

**Endpoint:** `POST /message/sendLocation/{instance}`

Send location coordinates.

```bash
curl -X POST \
  "${EVOLUTION_API_URL}/message/sendLocation/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "number": "5491165002220",
    "latitude": "-34.6037",
    "longitude": "-58.3816",
    "name": "Buenos Aires",
    "address": "Av. 9 de Julio, Buenos Aires"
  }'
```

#### Send Contact

**Endpoint:** `POST /message/sendContact/{instance}`

Send contact information.

```bash
curl -X POST \
  "${EVOLUTION_API_URL}/message/sendContact/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "number": "5491165002220",
    "contact": {
      "fullName": "John Doe",
      "wuid": "5491165002220@s.whatsapp.net",
      "phoneNumber": "5491165002220"
    }
  }'
```

#### Send List (Menu)

**Endpoint:** `POST /message/sendList/{instance}`

Send an interactive list menu.

```bash
curl -X POST \
  "${EVOLUTION_API_URL}/message/sendList/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "number": "5491165002220",
    "title": "Select Product",
    "description": "Choose a product from the list",
    "buttonText": "See options",
    "sections": [
      {
        "title": "Electronics",
        "rows": [
          {
            "rowId": "1",
            "title": "Smartphone",
            "description": "Latest model"
          },
          {
            "rowId": "2",
            "title": "Laptop",
            "description": "High performance"
          }
        ]
      }
    ]
  }'
```

---

### 5. Chat Management

#### Mark Message as Read

**Endpoint:** `POST /chat/markMessageAsRead/{instance}`

Mark one or more messages as read.

```bash
curl -X POST \
  "${EVOLUTION_API_URL}/chat/markMessageAsRead/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "readMessages": [
      {
        "remoteJid": "5491165002220@s.whatsapp.net",
        "fromMe": false,
        "id": "BAE594145F4C59B4"
      }
    ]
  }'
```

#### Delete Message for Everyone

**Endpoint:** `DELETE /chat/deleteMessageForEveryone/{instance}`

Delete a message for all participants (like WhatsApp's "Delete for Everyone").

```bash
curl -X DELETE \
  "${EVOLUTION_API_URL}/chat/deleteMessageForEveryone/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "BAE594145F4C59B4",
    "remoteJid": "5491165002220@s.whatsapp.net",
    "fromMe": true,
    "participant": "5491165002220@s.whatsapp.net"
  }'
```

#### Update Message

**Endpoint:** `POST /chat/updateMessage/{instance}`

Update the content of a sent message.

```bash
curl -X POST \
  "${EVOLUTION_API_URL}/chat/updateMessage/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "number": 5491165002220,
    "text": "Updated message content",
    "key": {
      "remoteJid": "5491165002220@s.whatsapp.net",
      "fromMe": true,
      "id": "BAE594145F4C59B4"
    }
  }'
```

#### Send Presence (Typing Status)

**Endpoint:** `POST /chat/sendPresence/{instance}`

Send typing indicator or "online" status.

```bash
curl -X POST \
  "${EVOLUTION_API_URL}/chat/sendPresence/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "number": "5491165002220",
    "status": "typing"
  }'
```

**Status values:** `typing`, `recording`, `paused`

---

### 6. Group Management

#### Fetch All Groups

**Endpoint:** `GET /group/fetchAllGroups/{instance}`

List all groups the instance is part of.

```bash
curl -X GET \
  "${EVOLUTION_API_URL}/group/fetchAllGroups/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}"
```

#### Create Group

**Endpoint:** `POST /group/create/{instance}`

Create a new WhatsApp group.

```bash
curl -X POST \
  "${EVOLUTION_API_URL}/group/create/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "My Group",
    "description": "Group description",
    "participants": [
      "5491165002220@s.whatsapp.net",
      "5491234567890@s.whatsapp.net"
    ]
  }'
```

#### Leave Group

**Endpoint:** `DELETE /group/leave/{instance}`

Leave a WhatsApp group.

```bash
curl -X DELETE \
  "${EVOLUTION_API_URL}/group/leave/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "groupJid": "120363012345678900@g.us"
  }'
```

#### Update Group Subject (Name)

**Endpoint:** `PUT /group/updateGroupSubject/{instance}`

Change group name.

```bash
curl -X PUT \
  "${EVOLUTION_API_URL}/group/updateGroupSubject/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "groupJid": "120363012345678900@g.us",
    "subject": "New Group Name"
  }'
```

---

## Security Best Practices

**CRITICAL SECURITY RULE:** Never print or expose API credentials in logs or terminal output.

```bash
# ✅ Correct: Credentials are not exposed
curl -H "apikey: ${EVOLUTION_API_KEY}" "${EVOLUTION_API_URL}/endpoint"

# ❌ Incorrect: Exposes credentials
echo "API Key: ${EVOLUTION_API_KEY}"
echo "${EVOLUTION_API_KEY}" | grep "..."
env | grep EVOLUTION_API_KEY
```

Always:
1. Reference environment variables directly in commands
2. Never use `echo` or `cat` to display credentials
3. Verify character count instead: `echo "${#EVOLUTION_API_KEY} characters loaded"`
4. Use pipes safely without exposing variable contents

---

## Common Issues & Troubleshooting

### WhatsApp Session Disconnected (401 Device Removed)

**Error Response:**
```json
{
  "disconnectionReasonCode": 401,
  "disconnectionObject": "{\"error\":{\"data\":{\"tag\":\"stream:error\",\"attrs\":{\"code\":\"401\"},\"content\":[{\"tag\":\"conflict\",\"attrs\":{\"type\":\"device_removed\"}}]}"
}
```

**Cause:** Your WhatsApp session was disconnected due to:
- Logging in from another device
- Session expiring or being removed
- Device lost connection for extended period

**Solution:**
1. Reconnect the instance with a fresh QR code
2. Scan the QR code from the phone device you want to use
3. Wait 30-60 seconds for the connection to stabilize

```bash
# Trigger new QR code
curl -X GET \
  "${EVOLUTION_API_URL}/instance/connect/${EVOLUTION_API_INSTANCE}?number=5491165002220" \
  -H "apikey: ${EVOLUTION_API_KEY}"
```

### Send Message Timeout

**Error Response:**
```json
{
  "status": 500,
  "error": "Internal Server Error",
  "response": {"message": "Timed Out"}
}
```

**Cause:** Instance is in `connecting` state or has unstable connection.

**Solution:**
1. Check instance connection state
2. Wait a few seconds and retry
3. If issue persists, reconnect the instance

```bash
# Check connection state
curl -X GET \
  "${EVOLUTION_API_URL}/instance/connectionState/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}"
```

### Message Reading Returns Mixed Chat Data

**Behavior:** When reading all messages, you may get messages from groups and individual chats mixed together.

**Solution:** Use the `chatId` parameter to filter messages from a specific chat:

```bash
# Get messages ONLY from specific chat
curl -X POST \
  "${EVOLUTION_API_URL}/chat/findMessages/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "chatId": "5491165002220@s.whatsapp.net",
    "limit": 5
  }'
```

---

## HTTP Status Codes

- `200 OK`: Request successful
- `201 Created`: Resource created successfully (messages, groups)
- `400 Bad Request`: Invalid payload or parameters
- `401 Unauthorized`: Invalid or missing API key
- `404 Not Found`: Instance or resource does not exist
- `429 Too Many Requests`: Rate limit exceeded
- `500 Server Error`: Internal server error

---

## Phone Number Format

Evolution API uses phone numbers with country codes (no + or spaces):

- **Argentina:** `549` prefix (e.g., `5491165002220`)
- **Brazil:** `55` prefix (e.g., `551133334444`)
- **Mexico:** `52` prefix (e.g., `525555555555`)
- **USA/Canada:** `1` prefix (e.g., `12125555555`)

JID formats in responses:
- **Individual:** `PHONENUMBER@s.whatsapp.net`
- **Group:** `GROUPID@g.us`

---

## Integration Platforms

Evolution API v2 supports integrations with:

- **Chatwoot:** CRM and customer support
- **Typebot:** No-code chatbot builder
- **Dify:** AI-powered workflows
- **OpenAI:** GPT integration
- **n8n:** Workflow automation
- **Flowise:** LLM flowchart UI
- **EvoAI:** Custom AI bots
- **RabbitMQ:** Message queue
- **Amazon SQS:** AWS message queue
- **Webhooks:** Custom endpoints
- **WebSocket:** Real-time events

---

## Resources

- **Official Docs:** https://doc.evolution-api.com
- **GitHub:** https://github.com/EvolutionAPI/evolution-api
- **OpenAPI Spec:** https://doc.evolution-api.com/openapi/openapi-v2.json
- **Postman Collection:** https://www.postman.com/agenciadgcode/evolution-api/
- **Community:** https://evolution-api.com

---

## Example: Complete Chat Reading Workflow

```bash
# 1. Verify API connection
curl -X GET "${EVOLUTION_API_URL}/" \
  -H "Content-Type: application/json"

# 2. Check instance state
curl -X GET \
  "${EVOLUTION_API_URL}/instance/connectionState/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}"

# Expected response for connected instance:
# {
#   "instance": {
#     "instanceName": "2220",
#     "state": "open"
#   }
# }

# 3. List all chats (returns 541+ chats with metadata)
curl -X POST \
  "${EVOLUTION_API_URL}/chat/findChats/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json"

# 4. Read last 5 messages from specific individual chat
curl -X POST \
  "${EVOLUTION_API_URL}/chat/findMessages/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "chatId": "5491165002220@s.whatsapp.net",
    "limit": 5
  }'

# Parse response to extract message content:
# jq '.[] | {from: .pushName, text: .message.conversation, timestamp: .messageTimestamp}'

# 5. Send a reply message
curl -X POST \
  "${EVOLUTION_API_URL}/message/sendText/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "number": "5491165002220",
    "text": "Thanks for your message!",
    "delay": 1000
  }'

# 6. Read media message (image/video/audio)
# Check message object for: imageMessage, videoMessage, audioMessage, etc.
# Extract URL from message and download if needed
```

## Practical Tips

### Extract Message Text by Type

```bash
# For text messages
jq '.[] | select(.messageType == "conversation") | .message.conversation'

# For image captions
jq '.[] | select(.messageType == "imageMessage") | .message.imageMessage'

# For audio messages (voice notes)
jq '.[] | select(.messageType == "audioMessage") | .message.audioMessage.url'

# For all messages with sender name and text
jq '.[] | {sender: .pushName, type: .messageType, text: (.message.conversation // "media")}'
```

### Filter by Timestamp

```bash
# Get messages from last 24 hours
# Convert Unix timestamp to seconds and compare
YESTERDAY=$(($(date +%s) - 86400))

curl -X POST \
  "${EVOLUTION_API_URL}/chat/findMessages/${EVOLUTION_API_INSTANCE}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"chatId\": \"5491165002220@s.whatsapp.net\",
    \"limit\": 100
  }" | jq ".[] | select(.messageTimestamp > $YESTERDAY)"
```

