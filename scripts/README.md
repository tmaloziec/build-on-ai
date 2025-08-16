# Build on AI - Scripts Directory

Production-ready automation scripts for Build on AI Linux distribution.

## 🤖 AI Models (`ai-models/`)

### `claude-models-test.sh` (1.8KB)
Test multiple Claude model integrations and API connectivity.
```bash
./scripts/ai-models/claude-models-test.sh
```

### `claude-test-fixed.sh` (3.6KB) ⭐ **PRODUCTION**
Production Claude integration with error handling and fallbacks.
```bash
./scripts/ai-models/claude-test-fixed.sh
```
**Status:** ✅ Working (requires API key setup)

### `claude-test.sh` (1.8KB)
Basic Claude API testing and validation.
```bash
./scripts/ai-models/claude-test.sh
```

## 🛠️ Installation (`installation/`)

### `install-bielik.sh` (9.4KB) ⭐ **POLISH AI**
Install and configure Bielik - Polish large language model.
```bash
./scripts/installation/install-bielik.sh
```
**Status:** ✅ Working (interactive menu)

### `install-hybrid-ai.sh` (7.7KB) ⭐ **HYBRID SYSTEM**
Setup hybrid AI system (local + cloud integration).
```bash
./scripts/installation/install-hybrid-ai.sh
```
**Status:** ✅ Working (Ollama + CodeLlama + Llama2 installed)

**Features:**
- Local AI (Ollama) - FREE usage
- Cloud AI integration with cost limits
- Automatic fallback protection
- Usage tracking and statistics

## 🧪 Testing (`testing/`)

### `test-build.sh` (378B)
Package build validation and syntax checking.
```bash
./scripts/testing/test-build.sh
```
**Status:** ✅ Working perfectly (PKGBUILD syntax OK)

## 🚀 Quick Start

1. **Install AI System:**
   ```bash
   ./scripts/installation/install-hybrid-ai.sh
   ```

2. **Test local AI:**
   ```bash
   ai-local 'What is Linux?'
   ```

3. **Test Polish AI:**
   ```bash
   ./scripts/installation/install-bielik.sh
   ```

4. **Validate packages:**
   ```bash
   ./scripts/testing/test-build.sh
   ```

## 📊 Test Results

| Script | Status | Description |
|--------|--------|-------------|
| `claude-test-fixed.sh` | ⚠️ API Key needed | Production Claude integration |
| `install-hybrid-ai.sh` | ✅ Working | Ollama + models installed |
| `install-bielik.sh` | ✅ Working | Polish AI ready |
| `test-build.sh` | ✅ Perfect | Package validation OK |

## 🛡️ Cost Protection

The hybrid AI system includes:
- **Daily limit:** $2.00 (configurable)
- **Monthly limit:** $20.00 (configurable)  
- **Auto-fallback** to local AI when limits reached
- **Usage tracking** and statistics

## 🔧 Available Commands (after installation)

```bash
ai 'question'           # Smart hybrid AI
ai-local 'question'     # Local AI (free)
ai-cloud 'question'     # Cloud AI (paid)
ai --stats              # Check spending
ai --set-limits         # Set spending limits
```

## 📦 System Requirements

- **OS:** Ubuntu 20.04+ or Arch Linux
- **RAM:** 8GB+ (16GB recommended for local AI)
- **Storage:** 10GB+ free space for AI models
- **Internet:** Required for model downloads and cloud AI

## 🎯 Production Ready

All scripts include:
- ✅ Error handling
- ✅ Progress indicators  
- ✅ User-friendly output
- ✅ Fallback mechanisms
- ✅ Configuration validation

---
**Build on AI** - Linux for Engineers 🚀
**Status:** Production Ready | **Models:** Local + Cloud | **Language:** PL + EN
