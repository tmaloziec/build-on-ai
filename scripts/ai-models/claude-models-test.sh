#!/bin/bash
# Final Working Claude API Test - Correct Model

echo "🤖 BuildOnAI - WORKING Claude API Test"
echo "======================================"

CLAUDE_API_KEY=$(cat ~/.config/build-on-ai/claude-api-key)

echo "🧪 Testing with CORRECT model name..."

# Test with multiple models to find working one
echo "📋 Testing different Claude models..."

# Test 1: Claude 3 Haiku
echo ""
echo "🧪 Test 1: Claude 3 Haiku..."
curl -s https://api.anthropic.com/v1/messages \
     --header "x-api-key: $CLAUDE_API_KEY" \
     --header "anthropic-version: 2023-06-01" \
     --header "content-type: application/json" \
     --data '{
         "model": "claude-3-haiku-20240307",
         "max_tokens": 100,
         "messages": [
             {"role": "user", "content": "Say: BuildOnAI Claude Haiku working!"}
         ]
     }' | python3 -m json.tool

echo ""
echo "🧪 Test 2: Claude 3 Sonnet..."
curl -s https://api.anthropic.com/v1/messages \
     --header "x-api-key: $CLAUDE_API_KEY" \
     --header "anthropic-version: 2023-06-01" \
     --header "content-type: application/json" \
     --data '{
         "model": "claude-3-sonnet-20240229",
         "max_tokens": 100,
         "messages": [
             {"role": "user", "content": "Say: BuildOnAI Claude Sonnet working!"}
         ]
     }' | python3 -m json.tool

echo ""
echo "🧪 Test 3: Claude 3.5 Sonnet (newer)..."
curl -s https://api.anthropic.com/v1/messages \
     --header "x-api-key: $CLAUDE_API_KEY" \
     --header "anthropic-version: 2023-06-01" \
     --header "content-type: application/json" \
     --data '{
         "model": "claude-3-5-sonnet-20240620",
         "max_tokens": 100,
         "messages": [
             {"role": "user", "content": "Say: BuildOnAI Claude 3.5 working!"}
         ]
     }' | python3 -m json.tool
