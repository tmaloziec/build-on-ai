#!/bin/bash
# BuildOnAI - Fixed Claude API Test (v2.0)

echo "🤖 BuildOnAI - Fixed Claude API Test (v2.0)"
echo "============================================="

# Create config directory
mkdir -p ~/.config/build-on-ai

API_KEY_FILE="$HOME/.config/build-on-ai/claude-api-key"

# Function to validate API key
validate_api_key() {
    local key="$1"
    if [[ -z "$key" ]]; then
        return 1
    fi
    if [[ ! "$key" =~ ^sk-ant-api03- ]]; then
        return 1
    fi
    if [[ ${#key} -lt 50 ]]; then
        return 1
    fi
    return 0
}

# Check if we have a valid saved API key
CLAUDE_API_KEY=""
if [[ -f "$API_KEY_FILE" ]]; then
    echo "📁 Checking saved API key..."
    SAVED_KEY=$(cat "$API_KEY_FILE" | tr -d '\n\r' | xargs)
    
    if validate_api_key "$SAVED_KEY"; then
        echo "✅ Valid API key found!"
        CLAUDE_API_KEY="$SAVED_KEY"
    else
        echo "❌ Saved API key is invalid (length: ${#SAVED_KEY})"
        echo "🗑️  Removing invalid key..."
        rm -f "$API_KEY_FILE"
    fi
fi

# If no valid key, ask for one
if [[ -z "$CLAUDE_API_KEY" ]]; then
    echo ""
    echo "🔑 Please enter your Claude API key:"
    echo "   📍 Get it from: https://console.anthropic.com"
    echo "   📍 Format: sk-ant-api03-..."
    echo ""
    read -s -p "Paste your Claude API key: " CLAUDE_API_KEY
    echo ""
    
    # Validate the entered key
    if ! validate_api_key "$CLAUDE_API_KEY"; then
        echo "❌ Invalid API key format!"
        echo "   ✅ Should start with: sk-ant-api03-"
        echo "   ✅ Should be 50+ characters long"
        echo "   ✅ Current length: ${#CLAUDE_API_KEY}"
        exit 1
    fi
    
    # Save the valid key
    echo "$CLAUDE_API_KEY" > "$API_KEY_FILE"
    chmod 600 "$API_KEY_FILE"
    echo "💾 API key saved to $API_KEY_FILE"
fi

echo ""
echo "🧪 Testing Claude API connection..."
echo "🔑 Key starts with: ${CLAUDE_API_KEY:0:15}..."
echo "🔑 Key length: ${#CLAUDE_API_KEY}"
echo "🔑 Format check: ✅"

# Test with curl
echo "📡 Sending test request to Claude API..."

RESPONSE=$(curl -s -w "HTTPSTATUS:%{http_code}" \
  -X POST \
  -H "Content-Type: application/json" \
  -H "x-api-key: $CLAUDE_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-3-haiku-20240307",
    "max_tokens": 100,
    "messages": [
      {
        "role": "user",
        "content": "Say \"BuildOnAI Claude integration working!\" and list 3 useful Linux commands."
      }
    ]
  }' \
  https://api.anthropic.com/v1/messages)

# Parse response
HTTP_STATUS=$(echo "$RESPONSE" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
RESPONSE_BODY=$(echo "$RESPONSE" | sed -e 's/HTTPSTATUS:.*//g')

echo "📊 Response status: $HTTP_STATUS"
echo ""

case "$HTTP_STATUS" in
    "200")
        echo "🎉 SUCCESS! Claude API is working!"
        echo "============================================================"
        
        # Try to extract content with Python if available
        if command -v python3 >/dev/null 2>&1; then
            CONTENT=$(echo "$RESPONSE_BODY" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data['content'][0]['text'])
except:
    print('Claude API responded successfully but could not parse content.')
" 2>/dev/null)
            echo "$CONTENT"
        else
            echo "Claude API responded successfully!"
        fi
        
        echo "============================================================"
        echo ""
        echo "🚀 BuildOnAI Claude integration is ready!"
        ;;
    "401")
        echo "❌ Unauthorized (401) - Invalid API key"
        echo "🗑️  Removing invalid key..."
        rm -f "$API_KEY_FILE"
        echo "💡 Get a new key from: https://console.anthropic.com"
        ;;
    "429")
        echo "⚠️  Rate limit exceeded (429)"
        echo "💡 Please wait and try again later"
        ;;
    *)
        echo "❌ Error: HTTP $HTTP_STATUS"
        echo "Response preview: ${RESPONSE_BODY:0:100}..."
        ;;
esac

echo ""
echo "✅ Test completed!"
