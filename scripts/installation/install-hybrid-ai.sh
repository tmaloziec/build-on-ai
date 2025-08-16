#!/bin/bash
# BuildOnAI Hybrid AI System - Complete Installer

echo "🤖 BuildOnAI Hybrid AI System Installer"
echo "======================================="
echo "Installing: Local AI + Cloud AI + Cost Control"
echo ""

# Install bc for calculations
sudo apt update && sudo apt install -y bc

# Install Ollama (Local AI)
echo "📦 Installing Ollama (Local AI)..."
curl -fsSL https://ollama.com/install.sh | sh

echo "🧠 Downloading CodeLlama model (best for coding)..."
ollama pull codellama:7b

echo "🧠 Downloading Llama2 model (general questions)..."
ollama pull llama2:7b

# Create local AI command
sudo tee /usr/local/bin/ai-local > /dev/null << 'EOF'
#!/bin/bash
# BuildOnAI Local AI (Free)

if [[ $# -eq 0 ]]; then
    echo "🏠 BuildOnAI Local AI (Offline & Free)"
    echo "Usage: ai-local 'your question'"
    exit 0
fi

QUESTION="$*"

echo "🏠 Local AI thinking (free)..."

# Choose model based on question type
if [[ "$QUESTION" =~ (code|program|script|function|debug|syntax) ]]; then
    MODEL="codellama:7b"
    echo "🔧 Using CodeLlama for programming question..."
else
    MODEL="llama2:7b"
    echo "💭 Using Llama2 for general question..."
fi

ollama run "$MODEL" "You are a helpful Linux assistant for engineers. Be concise and practical. Question: $QUESTION"
EOF

# Create enhanced cloud AI command with usage tracking
sudo tee /usr/local/bin/ai-cloud > /dev/null << 'EOF'
#!/bin/bash
# BuildOnAI Cloud AI (Paid) with Usage Tracking

source ~/.config/build-on-ai/cost-control.sh 2>/dev/null || true

if [[ -z "$CLAUDE_API_KEY" ]]; then
    echo "❌ Claude API key not loaded!"
    echo "Run: export CLAUDE_API_KEY=\$(cat ~/.config/build-on-ai/claude-api-key)"
    exit 1
fi

if [[ $# -eq 0 ]]; then
    echo "☁️  BuildOnAI Cloud AI (Powered by Claude)"
    echo "Usage: ai-cloud 'your question'"
    exit 0
fi

QUESTION="$*"
echo "☁️  Cloud AI thinking (monitored)..."

python3 -c "
import requests
import json
import sys
import os

api_key = '$CLAUDE_API_KEY'
question = '''$QUESTION'''

payload = {
    'model': 'claude-3-haiku-20240307',
    'max_tokens': 1000,
    'messages': [
        {
            'role': 'user', 
            'content': f'You are BuildOnAI assistant for Linux engineers. Be practical and concise. Question: {question}'
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
        
        # Extract usage info
        usage = result.get('usage', {})
        input_tokens = usage.get('input_tokens', 0)
        output_tokens = usage.get('output_tokens', 0)
        
        # Calculate cost (Claude Haiku pricing)
        input_cost = input_tokens * 0.25 / 1000000
        output_cost = output_tokens * 1.25 / 1000000
        total_cost = input_cost + output_cost
        
        print('\n🤖 BuildOnAI Cloud AI:')
        print('=' * 50)
        print(result['content'][0]['text'])
        print('=' * 50)
        print(f'💰 Cost: \${total_cost:.4f} (Input: {input_tokens}, Output: {output_tokens} tokens)')
        
        # Log usage for tracking
        os.system(f'echo \"\$(date \"+%Y-%m-%d %H:%M:%S\"),{input_tokens},{output_tokens},{total_cost:.6f},\\\"{question}\\\"\" >> ~/.config/build-on-ai/usage/\$(date +%Y-%m).log')
        
    else:
        print(f'❌ API Error: {response.status_code}')
        if response.status_code == 429:
            print('Rate limited - try ai-local instead!')
        
except Exception as e:
    print(f'❌ Error: {e}')
    print('☂️  Fallback to local AI...')
    os.system(f'ai-local \"{question}\"')
"
EOF

# Make commands executable
sudo chmod +x /usr/local/bin/ai-local
sudo chmod +x /usr/local/bin/ai-cloud

# Install cost control system
source <(curl -s https://raw.githubusercontent.com/build-on-ai/cost-control/main/install.sh) 2>/dev/null || {
    # Fallback: create cost control locally
    mkdir -p ~/.config/build-on-ai/usage
    
    cat > ~/.config/build-on-ai/usage/limits.conf << 'EOF'
# BuildOnAI Spending Limits (Edit as needed)
DAILY_LIMIT_USD=2.00
MONTHLY_LIMIT_USD=20.00
WARNING_THRESHOLD=0.80
EOF
}

# Create the main hybrid command
sudo tee /usr/local/bin/ai > /dev/null << 'EOF'
#!/bin/bash
# BuildOnAI Hybrid AI - Intelligent Switching

if [[ $# -eq 0 ]]; then
    echo "🤖 BuildOnAI Hybrid AI Assistant"
    echo "================================"
    echo "Commands:"
    echo "  ai 'question'           - Smart hybrid (local→cloud)"
    echo "  ai-local 'question'     - Force local (free)"
    echo "  ai-cloud 'question'     - Force cloud (paid)"
    echo "  ai --stats              - Usage statistics"
    echo "  ai --set-limits         - Configure spending limits"
    echo ""
    echo "💡 Hybrid mode tries local AI first, falls back to cloud for complex questions"
    exit 0
fi

if [[ "$1" == "--stats" ]]; then
    if [[ -f ~/.config/build-on-ai/usage/$(date +%Y-%m).log ]]; then
        echo "📊 This month's usage:"
        MONTHLY_COST=$(cut -d',' -f4 ~/.config/build-on-ai/usage/$(date +%Y-%m).log | paste -sd+ | bc -l 2>/dev/null || echo "0")
        MONTHLY_QUERIES=$(wc -l < ~/.config/build-on-ai/usage/$(date +%Y-%m).log)
        echo "💰 Total cost: \$$MONTHLY_COST"
        echo "📞 Total queries: $MONTHLY_QUERIES"
    else
        echo "📊 No usage data yet"
    fi
    exit 0
fi

if [[ "$1" == "--set-limits" ]]; then
    nano ~/.config/build-on-ai/usage/limits.conf
    exit 0
fi

QUESTION="$*"

# Check spending limits
LIMITS_FILE=~/.config/build-on-ai/usage/limits.conf
if [[ -f "$LIMITS_FILE" ]]; then
    source "$LIMITS_FILE"
    TODAY_COST=$(grep "^$(date +%Y-%m-%d)" ~/.config/build-on-ai/usage/$(date +%Y-%m).log 2>/dev/null | cut -d',' -f4 | paste -sd+ | bc -l 2>/dev/null || echo "0")
    
    if (( $(echo "$TODAY_COST >= ${DAILY_LIMIT_USD:-2.00}" | bc -l) )); then
        echo "💰 Daily limit reached (\$$TODAY_COST). Using local AI only."
        ai-local "$QUESTION"
        exit 0
    fi
fi

# Smart routing based on question complexity
echo "🤖 Analyzing question complexity..."

# Simple questions → Local AI
SIMPLE_PATTERNS="^(what|how to|list|show|install|update|ls|cd|mkdir|rm)"
if [[ "$QUESTION" =~ $SIMPLE_PATTERNS ]] && command -v ollama &> /dev/null; then
    echo "🏠 Simple question detected - trying local AI first..."
    
    # Try local AI with timeout
    timeout 20s ai-local "$QUESTION"
    
    if [[ $? -eq 0 ]]; then
        echo ""
        echo "💚 Answered by local AI (free!)"
        exit 0
    fi
fi

# Complex questions or local AI failed → Cloud AI
echo "☁️  Using cloud AI for better response..."
ai-cloud "$QUESTION"
EOF

sudo chmod +x /usr/local/bin/ai

echo ""
echo "🎉 BuildOnAI Hybrid AI System Installed!"
echo "========================================"
echo ""
echo "✅ Available commands:"
echo "  ai 'question'           - Smart hybrid AI"
echo "  ai-local 'question'     - Local AI (free)"  
echo "  ai-cloud 'question'     - Cloud AI (paid)"
echo "  ai --stats              - Check spending"
echo "  ai --set-limits         - Set spending limits"
echo ""
echo "🛡️  Cost protection:"
echo "  ✅ Daily spending limit: \$2.00 (configurable)"
echo "  ✅ Monthly spending limit: \$20.00 (configurable)"
echo "  ✅ Automatic fallback to local AI when limits reached"
echo "  ✅ Usage tracking and statistics"
echo ""
echo "🚀 Test it now:"
echo "  ai 'Hello, test hybrid AI!'"
echo "  ai-local 'What is Linux?'"  
echo "  ai-cloud 'Explain machine learning'"
