# Build on AI Core Package

## Overview
Essential metapackage for Build on AI distribution containing core tools for engineers and AI/ML development.

## Included Dependencies
- **Python Stack**: python, pip, numpy, scipy, matplotlib, pandas, scikit-learn
- **Development**: git, nano, vim, openssh
- **Utilities**: wget, curl, htop, tree
- **AI/ML**: jupyter-notebook

## Optional Dependencies
- python-tensorflow - Deep Learning framework
- python-pytorch - PyTorch deep learning
- docker - Containerization platform
- code - Visual Studio Code editor

## Installation
sudo pacman -S build-on-ai-core

## Post-Installation
The package automatically:
1. Creates /etc/build-on-ai/ configuration directory
2. Installs welcome message in /usr/share/build-on-ai/
3. Shows next steps for AI/ML setup
