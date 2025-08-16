#!/bin/bash
# BuildOnAI Confidence-Aware AI System
# Prevents hallucinations, enables honest "I don't know"

echo "🧠 BuildOnAI Confidence-Aware AI System"
echo "======================================="

# Create confidence detection system
create_confidence_system() {
    cat > ~/.config/build-on-ai/confidence-prompts.conf << 'EOF'
# Confidence-aware prompts for different models

# General honesty prompt
HONESTY_PROMPT="You must be completely honest. If you don't know something, say 'I don't know' or 'I'm not sure'. Never make up information. If uncertain, suggest where to find reliable information."

# Model-specific confidence prompts
BIELIK_PROMPT="Jesteś pomocnym asystentem, ale musisz być całkowicie uczciwy. Jeśli nie znasz odpowiedzi, powiedz 'Nie wiem' lub 'Nie jestem pewien'. Nigdy nie wymyślaj informacji. Jeśli masz wątpliwości, zasugeruj gdzie znaleźć wiarygodne informacje."

CODING_PROMPT="You are a coding assistant. Be honest about your knowledge. If you're not sure about a specific library, framework, or syntax, say so clearly. Suggest official documentation or testing approaches instead of guessing."

MATH_PROMPT="You are a mathematics assistant. Show your work step by step. If you're uncertain about a calculation or formula, state your uncertainty clearly. Double-check your arithmetic."

# Fallback suggestions for each domain
CODING_FALLBACK="For coding questions I can't answer confidently, try: official documentation, Stack Overflow, or ai-cloud for complex problems"
MATH_FALLBACK="For math problems I can't solve, try: ai-math command, Wolfram Alpha, or mathematical textbooks"
POLISH_FALLBACK="Dla polskich pytań których nie znam, spróbuj: ai-cloud z polskim promptem, lub oficjalne źródła polskie"
GENERAL_FALLBACK="For questions I can't answer, try: ai-cloud for complex queries, ai-code for programming, or ai-math for calculations"
EOF
}

# Create confidence detection wrapper
create_confidence_wrapper() {
    cat > ~/.config/build-on-ai/confidence-detector.py << 'EOF'
#!/usr/bin/env python3
"""
Confidence Detection System for BuildOnAI
Detects when AI models are uncertain and prevents hallucinations
"""

import re
import sys

class ConfidenceDetector:
    def __init__(self):
        # Phrases that indicate uncertainty or potential hallucination
        self.uncertainty_indicators = [
            # English uncertainty
            "i think", "i believe", "probably", "might be", "could be",
            "i'm not sure", "i don't know", "i'm uncertain", "not certain",
            "as far as i know", "to my knowledge", "i suspect", "likely",
            
            # Polish uncertainty  
            "myślę że", "prawdopodobnie", "może być", "nie jestem pewien",
            "nie wiem", "nie jestem pewna", "chyba", "wydaje mi się",
            
            # Hallucination indicators
            "i recall", "i remember", "from what i understand",
            "if i'm correct", "unless i'm mistaken"
        ]
        
        # Phrases that indicate the model is making stuff up
        self.hallucination_indicators = [
            "the latest version", "recent update", "new feature in",
            "according to the documentation", "the official guide states",
            "in version", "as of", "the current implementation"
        ]
        
        # Good honest phrases
        self.honest_indicators = [
            "i don't know", "i'm not sure", "i don't have information",
            "nie wiem", "nie jestem pewien", "nie mam informacji",
            "you should check", "recommend checking", "suggest looking at"
        ]
    
    def analyze_response(self, response):
        """Analyze response for confidence level"""
        response_lower = response.lower()
        
        uncertainty_count = sum(1 for phrase in self.uncertainty_indicators 
                               if phrase in response_lower)
        
        hallucination_count = sum(1 for phrase in self.hallucination_indicators 
                                 if phrase in response_lower)
        
        honest_count = sum(1 for phrase in self.honest_indicators 
                          if phrase in response_lower)
        
        # Calculate confidence score
        confidence_score = 1.0
        confidence_score -= uncertainty_count * 0.2
        confidence_score -= hallucination_count * 0.3
        confidence_score += honest_count * 0.1
        
        # Determine confidence level
        if confidence_score >= 0.8:
            return "HIGH", confidence_score
        elif confidence_score >= 0.5:
            return "MEDIUM", confidence_score
        else:
            return "LOW", confidence_score
    
    def should_fallback(self, response, confidence_level):
        """Determine if we should fallback to another model"""
        if confidence_level == "LOW":
            return True
            
        # Check for obvious hallucination patterns
        response_lower = response.lower()
        
        # If talking about specific versions/dates without uncertainty
        if any(phrase in response_lower for phrase in self.hallucination_indicators):
            if not any(phrase in response_lower for phrase in self.uncertainty_indicators):
                return True
                
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 confidence-detector.py 'AI response text'")
        sys.exit(1)
        
    response = " ".join(sys.argv[1:])
    detector = ConfidenceDetector()
    
    confidence_level, score = detector.analyze_response(response)
    should_fallback = detector.should_fallback(response, confidence_level)
    
    print(f"CONFIDENCE:{confidence_level}")
    print(f"SCORE:{score:.2f}")
    print(f"FALLBACK:{should_fallback}")

if __name__ == "__main__":
    main()
EOF

    chmod +x ~/.config/build-on-ai/confidence-detector.py
}

# Create smart AI wrapper with confidence checking
create_smart_ai_wrapper() {
    sudo tee /usr/local/bin/ai-smart-safe << 'EOF'
#!/bin/bash
# BuildOnAI Smart AI with Confidence Checking

source ~/.config/build-on-ai/confidence-prompts.conf 2>/dev/null

if [[ $# -eq 0 ]]; then
    echo "🧠 BuildOnAI Smart AI (Confidence-Aware)"
    echo "========================================="
    echo "Commands:"
    echo "  ai-smart-safe 'question'  - AI with hallucination protection"
    echo "  ai-honest 'question'      - Forces honest responses"
    echo "  ai-verify 'response'      - Check response confidence"
    echo ""
    echo "🛡️  Protection features:"
    echo "  ✅ Detects uncertainty and hallucinations"
    echo "  ✅ Automatic fallback to better models"
    echo "  ✅ Honest 'I don't know' responses"
    echo "  ✅ Suggests alternative resources"
    exit 0
fi

QUESTION="$*"

# Function to try a model with confidence checking
try_model_safely() {
    local model_command="$1"
    local question="$2"
    local model_name="$3"
    local fallback_suggestion="$4"
    
    echo "🧠 Trying $model_name..."
    
    # Get response from model
    local response=$($model_command "$question" 2>/dev/null)
    
    if [[ -z "$response" ]]; then
        echo "❌ $model_name unavailable"
        return 1
    fi
    
    # Check confidence
    local confidence_analysis=$(python3 ~/.config/build-on-ai/confidence-detector.py "$response")
    local confidence_level=$(echo "$confidence_analysis" | grep "CONFIDENCE:" | cut -d: -f2)
    local should_fallback=$(echo "$confidence_analysis" | grep "FALLBACK:" | cut -d: -f2)
    
    echo "📊 Confidence: $confidence_level"
    
    if [[ "$should_fallback" == "True" ]]; then
        echo "⚠️  $model_name seems uncertain or might be hallucinating"
        echo "🔄 Trying fallback approach..."
        return 1
    else
        echo ""
        echo "🤖 $model_name Response:"
        echo "=" * 50
        echo "$response"
        echo "=" * 50
        echo ""
        echo "✅ Confidence level: $confidence_level"
        return 0
    fi
}

# Smart fallback chain with confidence checking
echo "🛡️  BuildOnAI Smart AI with Hallucination Protection"
echo "======================================================"

# Detect question type and language
if [[ "$QUESTION" =~ [ąćęłńóśźżĄĆĘŁŃÓŚŹŻ] ]] || [[ "$QUESTION" =~ (jak|co|gdzie|dlaczego) ]]; then
    echo "🇵🇱 Polish question detected"
    
    # Try Bielik with honesty prompt
    BIELIK_QUESTION="$BIELIK_PROMPT

Pytanie: $QUESTION"
    
    if try_model_safely "ai-pl" "$BIELIK_QUESTION" "Bielik AI" "$POLISH_FALLBACK"; then
        exit 0
    fi
    
    echo "🔄 Bielik uncertain, trying Claude with Polish prompt..."
    ai-cloud "Odpowiedz uczciwie po polsku. Jeśli nie znasz odpowiedzi, powiedz 'nie wiem'. Pytanie: $QUESTION"
    exit 0
fi

# Coding questions
if [[ "$QUESTION" =~ (code|program|script|function|debug|syntax) ]]; then
    echo "💻 Coding question detected"
    
    CODING_QUESTION="$CODING_PROMPT

Question: $QUESTION"
    
    if try_model_safely "ai-code" "$CODING_QUESTION" "CodeLlama" "$CODING_FALLBACK"; then
        exit 0
    fi
    
    echo "🔄 CodeLlama uncertain, trying Claude..."
    ai-cloud "$HONESTY_PROMPT

Coding question: $QUESTION"
    exit 0
fi

# Math questions
if [[ "$QUESTION" =~ (math|calculate|equation|formula) ]]; then
    echo "🔢 Math question detected"
    
    MATH_QUESTION="$MATH_PROMPT

Problem: $QUESTION"
    
    if try_model_safely "ai-math" "$MATH_QUESTION" "Math AI" "$MATH_FALLBACK"; then
        exit 0
    fi
    
    echo "🔄 Math AI uncertain, trying Claude..."
    ai-cloud "$HONESTY_PROMPT

Math problem: $QUESTION"
    exit 0
fi

# General questions - try local first
echo "🗣️  General question - trying local AI first"

GENERAL_QUESTION="$HONESTY_PROMPT

Question: $QUESTION"

if try_model_safely "ai-local" "$GENERAL_QUESTION" "Local AI" "$GENERAL_FALLBACK"; then
    exit 0
fi

echo "🔄 Local AI uncertain, trying Claude for better response..."
ai-cloud "$GENERAL_QUESTION"
EOF

    sudo chmod +x /usr/local/bin/ai-smart-safe
}

# Create manual honesty enforcer
create_honesty_enforcer() {
    sudo tee /usr/local/bin/ai-honest << 'EOF'
#!/bin/bash
# Force AI to be honest and admit when it doesn't know

if [[ $# -eq 0 ]]; then
    echo "🛡️  BuildOnAI Honesty Enforcer"
    echo "Usage: ai-honest 'your question'"
    echo "Forces AI to admit uncertainty instead of hallucinating"
    exit 0
fi

QUESTION="$*"

HONESTY_PROMPT="You MUST be completely honest and accurate. Follow these rules strictly:

1. If you don't know something, say 'I don't know' clearly
2. If you're uncertain, express your uncertainty explicitly  
3. Never make up facts, version numbers, or documentation
4. If asking about something that might not exist, say so
5. Suggest reliable sources for verification
6. It's better to admit ignorance than to guess

Question: $QUESTION"

echo "🛡️  Enforcing honest response..."
ai-cloud "$HONESTY_PROMPT"
EOF

    sudo chmod +x /usr/local/bin/ai-honest
}

# Create confidence verification tool
create_confidence_verifier() {
    sudo tee /usr/local/bin/ai-verify << 'EOF'
#!/bin/bash
# Verify confidence of AI responses

if [[ $# -eq 0 ]]; then
    echo "🔍 BuildOnAI Response Verifier"
    echo "Usage: ai-verify 'AI response text'"
    echo "Analyzes AI response for confidence and potential hallucinations"
    exit 0
fi

RESPONSE="$*"

echo "🔍 Analyzing response confidence..."
python3 ~/.config/build-on-ai/confidence-detector.py "$RESPONSE"

echo ""
echo "💡 If confidence is LOW, consider:"
echo "  - Asking a more specific question"
echo "  - Using ai-honest for verified response"  
echo "  - Checking official documentation"
echo "  - Trying different specialized model"
EOF

    sudo chmod +x /usr/local/bin/ai-verify
}

# Update main ai command to use safe version by default
update_main_ai_command() {
    echo "🔄 Updating main AI command to use confidence-aware system..."
    
    # Backup original
    sudo cp /usr/local/bin/ai /usr/local/bin/ai-original 2>/dev/null
    
    # Update to use safe version by default
    sudo tee /usr/local/bin/ai << 'EOF'
#!/bin/bash
# BuildOnAI Main AI Command (Confidence-Aware)

if [[ "$1" == "--unsafe" ]]; then
    shift
    ai-original "$@"
    exit 0
fi

if [[ "$1" == "--verify" ]]; then
    shift
    ai-verify "$@"
    exit 0
fi

if [[ "$1" == "--honest" ]]; then
    shift  
    ai-honest "$@"
    exit 0
fi

if [[ $# -eq 0 ]]; then
    echo "🤖 BuildOnAI AI Assistant (Confidence-Aware)"
    echo "============================================="
    echo "Commands:"
    echo "  ai 'question'        - Smart AI with hallucination protection"
    echo "  ai --honest 'question' - Enforced honest responses"
    echo "  ai --verify 'response' - Check response confidence"
    echo "  ai --unsafe 'question' - Original AI without protection"
    echo "  ai --stats           - Usage statistics"
    echo "  ai --set-limits      - Configure spending limits"
    echo ""
    echo "🛡️  Protection: Detects uncertainty, prevents hallucinations"
    echo "🧠 Smart routing: Chooses best model for each question type"
    echo "💰 Cost control: Automatic local→cloud fallback"
    exit 0
fi

# Use confidence-aware version by default
ai-smart-safe "$@"
EOF

    sudo chmod +x /usr/local/bin/ai
}

# Installation menu
show_confidence_installation() {
    echo ""
    echo "🛡️  Confidence-Aware AI Installation:"
    echo "1. create_confidence_system    # Core confidence detection"
    echo "2. create_confidence_wrapper   # Python confidence analyzer"  
    echo "3. create_smart_ai_wrapper     # Safe AI with fallback chain"
    echo "4. create_honesty_enforcer     # Force honest responses"
    echo "5. create_confidence_verifier  # Manual response verification"
    echo "6. update_main_ai_command      # Make safety default"
    echo "7. ALL - Install complete system"
    echo ""
    echo "🎯 After installation:"
    echo "  ai 'question'          # Protected by default"
    echo "  ai --honest 'question' # Extra honesty enforcement"
    echo "  ai --verify 'response' # Check any AI response"
}

# Install everything
install_all_confidence_features() {
    echo "🚀 Installing complete confidence-aware system..."
    
    create_confidence_system
    create_confidence_wrapper
    create_smart_ai_wrapper
    create_honesty_enforcer  
    create_confidence_verifier
    update_main_ai_command
    
    echo ""
    echo "🎉 Confidence-Aware AI System Installed!"
    echo "========================================="
    echo ""
    echo "✅ Features enabled:"
    echo "  🛡️  Hallucination detection"
    echo "  🔄 Smart model fallback chains"  
    echo "  🤝 Honest 'I don't know' responses"
    echo "  🔍 Response confidence verification"
    echo "  🧠 Intelligent question routing"
    echo ""
    echo "🚀 Test it:"
    echo "  ai 'What is the capital of fake country Nonexistia?'"
    echo "  ai --honest 'Latest features in imaginary framework XYZ-2025'"
}

# Run installation menu
show_confidence_installation

