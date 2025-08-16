#!/bin/bash
# BuildOnAI Claude API Setup Script
# Automated setup for Claude integration

set -e

echo "🤖 BuildOnAI Claude AI Integration Setup"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}❌ Don't run this script as root!${NC}"
   echo "Run as regular user, script will ask for sudo when needed."
   exit 1
fi

# Function to check command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 is not installed${NC}"
        return 1
    else
        echo -e "${GREEN}✅ $1 found${NC}"
        return 0
    fi
}

echo -e "\n${BLUE}📋 Checking prerequisites...${NC}"

# Check required commands
check_command python3 || { echo "Install Python first: sudo pacman -S python"; exit 1; }
check_command pip || { echo "Install pip first: sudo pacman -S python-pip"; exit 1; }
check_command curl || { echo "Install curl first: sudo pacman -S curl"; exit 1; }

echo -e "\n${BLUE}📦 Installing Python dependencies...${NC}"

# Install Python packages
pip install --user requests anthropic

echo -e "\n${BLUE}🔑 Claude API Key Setup${NC}"
echo "You need a Claude API key from: https://console.anthropic.com/"
echo ""

# Check if API key already exists
if [[ -f ~/.config/build-on-ai/claude-api-key ]]; then
    echo -e "${YELLOW}⚠️  API key file already exists${NC}"
    read -p "Do you want to update it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping API key setup..."
        SKIP_API_KEY=true
    fi
fi

if [[ ! $SKIP_API_KEY ]]; then
    echo "Please paste your Claude API key (input will be hidden):"
    read -s CLAUDE_API_KEY
    
    if [[ -z "$CLAUDE_API_KEY" ]]; then
        echo -e "${YELLOW}⚠️  No API key provided. You can set it later with:${NC}"
        echo "echo 'your-api-key' > ~/.config/build-on-ai/claude-api-key"
    else
        # Create config directory
        mkdir -p ~/.config/build-on-ai
        
        # Save API key securely
        echo "$CLAUDE_API_KEY" > ~/.config/build-on-ai/claude-api-key
        chmod 600 ~/.config/build-on-ai/claude-api-key
        
        echo -e "${GREEN}✅ API key saved securely${NC}"
        
        # Test API key
        echo -e "\n${BLUE}🧪 Testing Claude API connection...${NC}"
        if python3 -c "
import requests
import os
try:
    with open(os.path.expanduser('~/.config/build-on-ai/claude-api-key'), 'r') as f:
        api_key = f.read().strip()
    
    response = requests.post(
        'https://api.anthropic.com/v1/messages',
        headers={
            'Content-Type': 'application/json',
            'x-api-key': api_key,
            'anthropic-version': '2023-06-01'
        },
        json={
            'model': 'claude-3-haiku-20240307',
            'max_tokens': 10,
            'messages': [{'role': 'user', 'content': 'Hi'}]
        }
    )
    
    if response.status_code == 200:
        print('✅ API connection successful!')
    else:
        print(f'❌ API test failed: {response.status_code}')
        print(response.text)
except Exception as e:
    print(f'❌ API test error: {e}')
"; then
            echo -e "${GREEN}✅ Claude API is working!${NC}"
        else
            echo -e "${RED}❌ API test failed. Check your key.${NC}"
        fi
    fi
fi

echo -e "\n${BLUE}📁 Creating BuildOnAI directories...${NC}"

# Create necessary directories
sudo mkdir -p /etc/build-on-ai
sudo mkdir -p /usr/share/build-on-ai/ai-assistant
sudo mkdir -p /var/lib/build-on-ai/ai-logs

# Set permissions
sudo chown -R $USER:$USER ~/.config/build-on-ai 2>/dev/null || true

echo -e "\n${BLUE}🔧 Installing AI Assistant commands...${NC}"

# Create the main AI assistant script
sudo tee /usr/local/bin/ai > /dev/null << 'EOF'
#!/bin/bash
# BuildOnAI AI Assistant - Quick command

API_KEY_FILE="$HOME/.config/build-on-ai/claude-api-key"

if [[ ! -f "$API_KEY_FILE" ]]; then
    echo "❌ Claude API key not found!"
    echo "Run: echo 'your-api-key' > ~/.config/build-on-ai/claude-api-key"
    exit 1
fi

API_KEY=$(cat "$API_KEY_FILE")

if [[ $# -eq 0 ]]; then
    echo "🤖 BuildOnAI AI Assistant"
    echo "Usage: ai 'your question'"
    echo "Example: ai 'How do I install TensorFlow?'"
    exit 0
fi

QUESTION="$*"

echo "🤖 AI Assistant is thinking..."

python3 -c "
import requests
import json
import sys

api_key = '$API_KEY'
question = '''$QUESTION'''

system_prompt = '''You are the BuildOnAI assistant. Help with Linux, engineering software, AI/ML tools, and system administration. Give practical, working commands. Be concise but helpful.'''

payload = {
    'model': 'claude-3-haiku-20240307',
    'max_tokens': 1000,
    'messages': [{'role': 'user', 'content': question}],
    'system': system_prompt
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
        print('\n🤖 BuildOnAI AI Assistant:')
        print('=' * 50)
        print(result['content'][0]['text'])
        print('=' * 50)
    else:
        print(f'❌ API Error: {response.status_code}')
        print(response.text)
        
except Exception as e:
    print(f'❌ Error: {e}')
"
EOF

# Make it executable
sudo chmod +x /usr/local/bin/ai

echo -e "\n${BLUE}🚀 Creating additional AI commands...${NC}"

# AI package installer
sudo tee /usr/local/bin/ai-install > /dev/null << 'EOF'
#!/bin/bash
# AI-powered package installer

if [[ $# -eq 0 ]]; then
    echo "Usage: ai-install <package-description>"
    echo "Example: ai-install machine learning tools"
    exit 0
fi

echo "🤖 AI Assistant: Analyzing package request..."
ai "I want to install $*. What exact pacman commands should I run? Give me the specific commands for Arch Linux."
EOF

sudo chmod +x /usr/local/bin/ai-install

# AI troubleshooter
sudo tee /usr/local/bin/ai-fix > /dev/null << 'EOF'
#!/bin/bash
# AI system diagnostics and troubleshooting

echo "🔍 AI Assistant: Running system diagnosis..."

# Gather system info
SYSTEM_INFO=$(cat << EOM
System: $(uname -a)
Memory: $(free -h | head -2)
Disk: $(df -h / | tail -1)
Network: $(ip route | head -1)
Last errors: $(journalctl -p err --since "1 hour ago" --no-pager -n 5 | tail -5)
EOM
)

if [[ $# -eq 0 ]]; then
    ai "Analyze this Linux system and suggest optimizations or fixes: $SYSTEM_INFO"
else
    ai "I have this problem: $*. Here's my system info: $SYSTEM_INFO. How do I fix it?"
fi
EOF

sudo chmod +x /usr/local/bin/ai-fix

echo -e "\n${BLUE}⚙️  Setting up shell integration...${NC}"

# Add to bashrc if not already there
BASHRC_LINE='# BuildOnAI AI Assistant aliases'
if ! grep -q "$BASHRC_LINE" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "$BASHRC_LINE" >> ~/.bashrc
    echo "alias ai-help='ai'" >> ~/.bashrc
    echo "alias ask-ai='ai'" >> ~/.bashrc
    echo "" >> ~/.bashrc
fi

echo -e "\n${GREEN}🎉 BuildOnAI Claude AI Integration Setup Complete!${NC}"
echo ""
echo -e "${BLUE}Available commands:${NC}"
echo -e "  ${YELLOW}ai 'question'${NC}          - Ask AI anything"
echo -e "  ${YELLOW}ai-install 'software'${NC}  - AI-powered package installation"
echo -e "  ${YELLOW}ai-fix${NC}                 - System diagnostics"
echo -e "  ${YELLOW}ai-fix 'problem'${NC}       - Troubleshoot specific issues"
echo ""
echo -e "${BLUE}Examples:${NC}"
echo -e "  ai 'How do I setup Python for machine learning?'"
echo -e "  ai-install tensorflow pytorch"
echo -e "  ai-fix 'wifi not working'"
echo ""
echo -e "${YELLOW}⚠️  Remember to restart your terminal or run: source ~/.bashrc${NC}"
echo ""
echo -e "${GREEN}🚀 BuildOnAI is now AI-powered! Welcome to the future of Linux!${NC}"
