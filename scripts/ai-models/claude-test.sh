#!/bin/bash
# Quick Claude API Test for BuildOnAI

echo "🤖 BuildOnAI - Quick Claude API Test"
echo "====================================="

# Get API key from user
echo "Paste your Claude API key (sk-ant-...):"
read -s CLAUDE_API_KEY

if [[ -z "$CLAUDE_API_KEY" ]]; then
    echo "❌ No API key provided!"
    exit 1
fi

echo ""
echo "🧪 Testing Claude API connection..."

# Test API with simple request
python3 -c "
import requests
import json

api_key = '$CLAUDE_API_KEY'

payload = {
    'model': 'claude-3-haiku-20240307',
    'max_tokens': 100,
    'messages': [
        {
            'role': 'user', 
            'content': 'Say \"BuildOnAI Claude integration working!\" and list 3 Linux commands.'
        }
    ]
}

try:
    response = requests.post(
        'https://api.anthropic.com/v1/messages',
        headers={
            'Content-Type': 'application/json',
            'x-api-key': api_key,
            'anthropic-version': '2023-06-01'
        },
        json=payload
    )
    
    if response.status_code == 200:
        result = response.json()
        print('✅ SUCCESS! Claude API is working!')
        print('=' * 50)
        print(result['content'][0]['text'])
        print('=' * 50)
        print('🚀 Ready for BuildOnAI integration!')
    else:
        print(f'❌ API Error: {response.status_code}')
        print(response.text)
        
except Exception as e:
    print(f'❌ Connection Error: {e}')
    print('Check your internet connection and API key.')
"

echo ""
echo "💾 Saving API key for future use..."
mkdir -p ~/.config/build-on-ai
echo "$CLAUDE_API_KEY" > ~/.config/build-on-ai/claude-api-key
chmod 600 ~/.config/build-on-ai/claude-api-key
echo "✅ API key saved to ~/.config/build-on-ai/claude-api-key"
