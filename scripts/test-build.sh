#!/bin/bash
echo "=== Testing Build on AI Core Package ==="
echo "Package: build-on-ai-core"
echo "Version: 1.0.0"

echo "PKGBUILD syntax check..."
cd ~/build-on-ai/packages/build-on-ai-core/  # <- Zmiana tutaj
if bash -n PKGBUILD; then
    echo "✓ PKGBUILD syntax: OK"
else
    echo "✗ PKGBUILD syntax: ERROR"
    exit 1
fi

echo "🚀 Package ready for Arch Linux build!"
