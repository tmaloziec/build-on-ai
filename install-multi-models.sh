#!/bin/bash
# BuildOnAI Multi-Model AI System

echo "🧠 BuildOnAI Multi-Model AI System"
echo "=================================="
echo "Installing multiple specialized AI models..."

# Install additional Ollama models
install_coding_models() {
    echo "💻 Installing Coding AI Models..."
    
    # Code generation and debugging
    ollama pull codellama:13b          # Better coding than 7b
    ollama pull phind-codellama:34b    # Optimized for code search
    ollama pull magicoder:7b           # Microsoft's code model
    ollama pull codeqwen:7b            # Alibaba's coding model
    
    echo "✅ Coding models installed!"
}

install_general_models() {
    echo "🗣️ Installing General AI Models..."
    
    # General conversation and reasoning
    ollama pull llama2:13b             # Better than 7b
    ollama pull llama2:70b             # Highest quality (needs 64GB+ RAM)
    ollama pull mistral:7b             # Fast and efficient
    ollama pull orca-mini:3b           # Ultra lightweight
    ollama pull neural-chat:7b         # Optimized for conversations
    
    echo "✅ General models installed!"
}

install_specialized_models() {
    echo "🔬 Installing Specialized AI Models..."
    
    # Domain-specific models
    ollama pull llama2-uncensored:7b   # For technical discussions
    ollama pull vicuna:7b              # Good reasoning
    ollama pull wizard-math:7b         # Mathematical problems
    ollama pull meditron:7b            # Medical/scientific content
    ollama pull sqlcoder:7b            # Database queries
    
    echo "✅ Specialized models installed!"
}

install_multilingual_models() {
    echo "🌍 Installing Multilingual Models..."
    
    # Languages other than English
    ollama pull llama2:7b-chat         # Better chat format
    ollama pull openchat:7b            # Multilingual support
    ollama pull starling-lm:7b         # Good for non-English
    
    echo "✅ Multilingual models installed!"
}

# Create model selector system
create_smart_model_selector() {
    cat > /usr/local/bin/ai-select << 'EOF'
#!/bin/bash
# BuildOnAI Smart Model Selector

select_best_model() {
    local question="$1"
    local available_models=($(ollama list | tail -n +2 | awk '{print $1}' | grep -v "^NAME"))
    
    # Coding questions
    if [[ "$question" =~ (code|program|script|function|debug|syntax|programming|algorithm|database|sql) ]]; then
        for model in "magicoder:7b" "codellama:13b" "phind-codellama:34b" "codellama:7b"; do
            if printf '%s\n' "${available_models[@]}" | grep -q "^$model$"; then
                echo "$model"
                return
            fi
        done
    fi
    
    # Mathematical questions
    if [[ "$question" =~ (math|calculate|equation|formula|statistics|probability) ]]; then
        for model in "wizard-math:7b" "llama2:13b" "llama2:7b"; do
            if printf '%s\n' "${available_models[@]}" | grep -q "^$model$"; then
                echo "$model"
                return
            fi
        done
    fi
    
    # Complex reasoning (use largest available)
    if [[ "$question" =~ (explain|analyze|compare|complex|detailed|architecture) ]]; then
        for model in "llama2:70b" "llama2:13b" "codellama:13b" "llama2:7b"; do
            if printf '%s\n' "${available_models[@]}" | grep -q "^$model$"; then
                echo "$model"
                return
            fi
        done
    fi
    
    # Quick questions (use fastest)
    if [[ "$question" =~ (what|how|list|show|quick|simple) ]]; then
        for model in "orca-mini:3b" "mistral:7b" "llama2:7b"; do
            if printf '%s\n' "${available_models[@]}" | grep -q "^$model$"; then
                echo "$model"
                return
            fi
        done
    fi
    
    # Default fallback
    for model in "llama2:7b" "codellama:7b" "mistral:7b"; do
        if printf '%s\n' "${available_models[@]}" | grep -q "^$model$"; then
            echo "$model"
            return
        fi
    done
    
    echo "llama2:7b"  # Ultimate fallback
}

if [[ $# -eq 0 ]]; then
    echo "🧠 BuildOnAI Model Selector"
    echo "Usage: ai-select 'your question'"
    echo ""
    echo "📋 Available models:"
    ollama list
    exit 0
fi

QUESTION="$*"
SELECTED_MODEL=$(select_best_model "$QUESTION")

echo "🧠 Selected model: $SELECTED_MODEL"
echo "🤖 Processing..."

ollama run "$SELECTED_MODEL" "You are BuildOnAI assistant for engineers. Be practical and concise. Question: $QUESTION"
EOF

    sudo chmod +x /usr/local/bin/ai-select
}

# Create model-specific commands
create_specialized_commands() {
    echo "🎯 Creating specialized AI commands..."
    
    # Code assistant
    sudo tee /usr/local/bin/ai-code << 'EOF'
#!/bin/bash
if command -v ollama &> /dev/null; then
    MODELS=("magicoder:7b" "codellama:13b" "phind-codellama:34b" "codellama:7b")
    for model in "${MODELS[@]}"; do
        if ollama list | grep -q "$model"; then
            echo "💻 Using $model for coding..."
            ollama run "$model" "You are an expert programmer. Help with this coding question: $*"
            exit 0
        fi
    done
fi
echo "❌ No coding models available"
EOF

    # Math assistant
    sudo tee /usr/local/bin/ai-math << 'EOF'
#!/bin/bash
if command -v ollama &> /dev/null; then
    MODELS=("wizard-math:7b" "llama2:13b" "llama2:7b")
    for model in "${MODELS[@]}"; do
        if ollama list | grep -q "$model"; then
            echo "🔢 Using $model for math..."
            ollama run "$model" "You are a mathematics expert. Solve this problem step by step: $*"
            exit 0
        fi
    done
fi
echo "❌ No math models available"
EOF

    # Quick assistant (fastest model)
    sudo tee /usr/local/bin/ai-quick << 'EOF'
#!/bin/bash
if command -v ollama &> /dev/null; then
    MODELS=("orca-mini:3b" "mistral:7b" "llama2:7b")
    for model in "${MODELS[@]}"; do
        if ollama list | grep -q "$model"; then
            echo "⚡ Using $model for quick answer..."
            ollama run "$model" "Give a brief, practical answer: $*"
            exit 0
        fi
    done
fi
echo "❌ No quick models available"
EOF

    # Best quality (largest model)
    sudo tee /usr/local/bin/ai-best << 'EOF'
#!/bin/bash
if command -v ollama &> /dev/null; then
    MODELS=("llama2:70b" "llama2:13b" "codellama:13b" "llama2:7b")
    for model in "${MODELS[@]}"; do
        if ollama list | grep -q "$model"; then
            echo "🏆 Using $model for best quality..."
            ollama run "$model" "Provide a detailed, expert-level response: $*"
            exit 0
        fi
    done
fi
echo "❌ No models available"
EOF

    sudo chmod +x /usr/local/bin/ai-{code,math,quick,best}
}

# Update main ai-local command to use smart selection
update_ai_local() {
    sudo tee /usr/local/bin/ai-local << 'EOF'
#!/bin/bash
# BuildOnAI Local AI (Multi-Model)

if [[ $# -eq 0 ]]; then
    echo "🏠 BuildOnAI Multi-Model Local AI"
    echo "Commands:"
    echo "  ai-local 'question'  - Smart model selection"
    echo "  ai-code 'question'   - Best for programming"
    echo "  ai-math 'question'   - Best for mathematics"
    echo "  ai-quick 'question'  - Fastest response"
    echo "  ai-best 'question'   - Highest quality"
    echo "  ai-select 'question' - Manual model selection"
    echo ""
    echo "📋 Installed models:"
    ollama list
    exit 0
fi

# Use smart model selection
ai-select "$*"
EOF

    sudo chmod +x /usr/local/bin/ai-local
}

# Installation menu
show_installation_menu() {
    echo ""
    echo "🎯 Model Installation Options:"
    echo "1. install_coding_models      # Programming & debugging"
    echo "2. install_general_models     # General conversation"  
    echo "3. install_specialized_models # Domain-specific"
    echo "4. install_multilingual_models # Non-English support"
    echo "5. ALL - Install everything (needs ~50GB disk space)"
    echo ""
    echo "📊 Model size guide:"
    echo "  3b models  = ~2GB   (orca-mini)"
    echo "  7b models  = ~4GB   (most models)"
    echo "  13b models = ~7GB   (better quality)"
    echo "  70b models = ~40GB  (best quality, needs 64GB+ RAM)"
    echo ""
    echo "🎯 After installation, run:"
    echo "create_smart_model_selector"
    echo "create_specialized_commands"
    echo "update_ai_local"
}

# Run installation menu
show_installation_menu
