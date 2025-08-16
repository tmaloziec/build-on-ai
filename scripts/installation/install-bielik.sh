#!/bin/bash
# Bielik AI Integration dla BuildOnAI - Polski AI Assistant

echo "🦅 Dodawanie Bielik AI do BuildOnAI"
echo "=================================="

# Bielik jest dostępny przez różne platformy
install_bielik_options() {
    echo "🇵🇱 Opcje instalacji Bielik AI:"
    echo ""
    echo "1. Bielik przez Ollama (zalecane)"
    echo "2. Bielik przez HuggingFace Transformers"
    echo "3. Bielik API (jeśli dostępne)"
    echo "4. Wszystkie opcje"
}

# Opcja 1: Bielik przez Ollama
install_bielik_ollama() {
    echo "📦 Instalowanie Bielik przez Ollama..."
    
    # Sprawdź czy Bielik jest dostępny w Ollama
    if ollama list | grep -q "bielik"; then
        echo "✅ Bielik już zainstalowany!"
        return 0
    fi
    
    # Spróbuj pobrać Bielik
    echo "🧠 Pobieranie Bielik AI model..."
    
    # Różne wersje Bielik do sprawdzenia
    BIELIK_MODELS=(
        "bielik-7b"
        "bielik-7b-instruct"
        "bielik-13b"
        "bielik"
        "speakleash/bielik-7b-instruct-v0.1"
    )
    
    for model in "${BIELIK_MODELS[@]}"; do
        echo "🔍 Próba instalacji: $model"
        if timeout 60s ollama pull "$model" 2>/dev/null; then
            echo "✅ Bielik zainstalowany jako: $model"
            echo "$model" > ~/.config/build-on-ai/bielik-model
            return 0
        fi
    done
    
    echo "⚠️  Bielik nie jest dostępny w standardowym Ollama"
    echo "💡 Spróbujemy alternatywnych metod..."
    return 1
}

# Opcja 2: Bielik przez HuggingFace
install_bielik_transformers() {
    echo "🤗 Instalowanie Bielik przez HuggingFace Transformers..."
    
    # Instaluj wymagane biblioteki
    pip3 install torch transformers accelerate sentencepiece
    
    # Utwórz Bielik script
    cat > ~/build-on-ai/bielik-hf.py << 'EOF'
#!/usr/bin/env python3
"""
Bielik AI przez HuggingFace Transformers
"""

import sys
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch

class BielikAI:
    def __init__(self):
        self.model_name = "speakleash/bielik-7b-instruct-v0.1"
        self.tokenizer = None
        self.model = None
        self.loaded = False
        
    def load_model(self):
        """Załaduj model Bielik"""
        if self.loaded:
            return True
            
        try:
            print("🦅 Ładowanie Bielik AI model...")
            
            self.tokenizer = AutoTokenizer.from_pretrained(self.model_name)
            self.model = AutoModelForCausalLM.from_pretrained(
                self.model_name,
                torch_dtype=torch.float16,
                device_map="auto",
                low_cpu_mem_usage=True
            )
            
            self.loaded = True
            print("✅ Bielik AI załadowany!")
            return True
            
        except Exception as e:
            print(f"❌ Błąd ładowania Bielik: {e}")
            return False
    
    def ask(self, question):
        """Zadaj pytanie Bielik AI"""
        if not self.load_model():
            return "❌ Nie udało się załadować Bielik AI"
            
        try:
            # Format prompt dla Bielik
            prompt = f"### Instrukcja:\nJesteś pomocnym asystentem AI dla inżynierów pracujących z Linux. Odpowiadaj praktycznie i zwięźle.\n\n### Pytanie:\n{question}\n\n### Odpowiedź:\n"
            
            inputs = self.tokenizer(prompt, return_tensors="pt").to(self.model.device)
            
            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    max_new_tokens=512,
                    temperature=0.7,
                    do_sample=True,
                    pad_token_id=self.tokenizer.eos_token_id
                )
            
            response = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
            
            # Wyciągnij odpowiedź (po "### Odpowiedź:")
            if "### Odpowiedź:" in response:
                answer = response.split("### Odpowiedź:")[-1].strip()
                return answer
            else:
                return response[len(prompt):].strip()
                
        except Exception as e:
            return f"❌ Błąd generowania odpowiedzi: {e}"

def main():
    if len(sys.argv) < 2:
        print("🦅 Bielik AI - Polski Assistant")
        print("Usage: python3 bielik-hf.py 'twoje pytanie'")
        sys.exit(1)
        
    question = " ".join(sys.argv[1:])
    
    bielik = BielikAI()
    response = bielik.ask(question)
    
    print("\n🦅 Bielik AI:")
    print("=" * 50)
    print(response)
    print("=" * 50)

if __name__ == "__main__":
    main()
EOF

    chmod +x ~/build-on-ai/bielik-hf.py
    echo "✅ Bielik HuggingFace script utworzony!"
}

# Opcja 3: Sprawdź Bielik API
check_bielik_api() {
    echo "🌐 Sprawdzanie dostępności Bielik API..."
    
    # Możliwe endpointy Bielik API
    BIELIK_ENDPOINTS=(
        "https://api.bielik.ai"
        "https://bielik-api.pl"
        "https://api.speakleash.org"
    )
    
    for endpoint in "${BIELIK_ENDPOINTS[@]}"; do
        echo "🔍 Sprawdzanie: $endpoint"
        if curl -s --max-time 5 "$endpoint" >/dev/null 2>&1; then
            echo "✅ Znaleziono API: $endpoint"
            echo "$endpoint" > ~/.config/build-on-ai/bielik-api-endpoint
            return 0
        fi
    done
    
    echo "⚠️  Brak dostępnych API endpoints"
    return 1
}

# Stwórz polskie komendy AI
create_polish_ai_commands() {
    echo "🇵🇱 Tworzenie polskich komend AI..."
    
    # Komenda ai-pl (Bielik)
    sudo tee /usr/local/bin/ai-pl << 'EOF'
#!/bin/bash
# BuildOnAI - Polski AI Assistant (Bielik)

if [[ $# -eq 0 ]]; then
    echo "🦅 BuildOnAI - Polski AI Assistant (Bielik)"
    echo "Usage: ai-pl 'twoje pytanie po polsku'"
    echo ""
    echo "Przykłady:"
    echo "  ai-pl 'Jak zainstalować Python w Ubuntu?'"
    echo "  ai-pl 'Wyjaśnij co to jest machine learning'"
    echo "  ai-pl 'Pomóż z debugowaniem skryptu bash'"
    exit 0
fi

QUESTION="$*"

# Spróbuj Bielik przez Ollama
if [[ -f ~/.config/build-on-ai/bielik-model ]]; then
    BIELIK_MODEL=$(cat ~/.config/build-on-ai/bielik-model)
    if ollama list | grep -q "$BIELIK_MODEL"; then
        echo "🦅 Używam Bielik przez Ollama..."
        ollama run "$BIELIK_MODEL" "Jesteś pomocnym asystentem AI dla polskich inżynierów. Odpowiadaj po polsku, praktycznie i zwięźle. Pytanie: $QUESTION"
        exit 0
    fi
fi

# Spróbuj Bielik przez HuggingFace
if [[ -f ~/build-on-ai/bielik-hf.py ]]; then
    echo "🦅 Używam Bielik przez HuggingFace..."
    python3 ~/build-on-ai/bielik-hf.py "$QUESTION"
    exit 0
fi

# Fallback na Claude z polskim promptem
if [[ -n "$CLAUDE_API_KEY" ]]; then
    echo "🦅 Fallback na Claude z polskim promptem..."
    ai-cloud "Odpowiedz po polsku na to pytanie: $QUESTION"
    exit 0
fi

# Ostateczny fallback na lokalny model z polskim promptem
echo "🦅 Używam lokalnego AI z polskim promptem..."
ai-local "Answer in Polish language: $QUESTION"
EOF

    sudo chmod +x /usr/local/bin/ai-pl
    
    # Dodaj aliasy polskie
    cat >> ~/.bashrc << 'EOF'

# BuildOnAI - Polskie aliasy AI
alias pytaj='ai-pl'
alias pomoc='ai-pl'
alias asystent='ai-pl'
EOF

    echo "✅ Polskie komendy utworzone!"
    echo "Dostępne: ai-pl, pytaj, pomoc, asystent"
}

# Update smart model selector dla języka polskiego
update_model_selector_polish() {
    echo "🇵🇱 Aktualizowanie selektora dla języka polskiego..."
    
    # Backup oryginalnego ai-select
    if [[ -f /usr/local/bin/ai-select ]]; then
        sudo cp /usr/local/bin/ai-select /usr/local/bin/ai-select.backup
    fi
    
    # Dodaj detekcję języka polskiego
    sudo tee -a /usr/local/bin/ai-select << 'EOF'

# Detekcja języka polskiego
detect_polish() {
    local text="$1"
    # Polskie znaki i słowa
    if [[ "$text" =~ [ąćęłńóśźżĄĆĘŁŃÓŚŹŻ] ]] || \
       [[ "$text" =~ (jak|co|gdzie|dlaczego|kiedy|czy|żeby|bardzo|przez|oraz|tylko|także|może|należy) ]]; then
        return 0  # Polski
    fi
    return 1  # Nie polski
}

# Jeśli pytanie po polsku, użyj Bielik
if detect_polish "$QUESTION"; then
    echo "🇵🇱 Wykryto język polski - używam Bielik AI..."
    ai-pl "$QUESTION"
    exit 0
fi
EOF

    echo "✅ Selektor zaktualizowany dla języka polskiego!"
}

# Menu instalacji
show_bielik_menu() {
    echo ""
    echo "🦅 Menu instalacji Bielik AI:"
    echo "1. install_bielik_ollama        # Przez Ollama (zalecane)"
    echo "2. install_bielik_transformers  # Przez HuggingFace" 
    echo "3. check_bielik_api            # Sprawdź API"
    echo "4. create_polish_ai_commands   # Polskie komendy"
    echo "5. update_model_selector_polish # Update selektor"
    echo "6. ALL - Zainstaluj wszystko"
    echo ""
    echo "🎯 Po instalacji:"
    echo "  ai-pl 'Jak zainstalować Docker?'"
    echo "  pytaj 'Co to jest Kubernetes?'"
    echo "  pomoc 'Debugowanie bash script'"
}

# Funkcja instalująca wszystko
install_all_bielik() {
    echo "🚀 Instalowanie wszystkich opcji Bielik AI..."
    
    install_bielik_ollama
    install_bielik_transformers  
    check_bielik_api
    create_polish_ai_commands
    update_model_selector_polish
    
    echo "🎉 Bielik AI kompletnie zintegrowany!"
}

# Uruchom menu
install_bielik_options
show_bielik_menu
