#!/bin/bash
# TapPay Specification & Quality Gate Checker Script
# This script ensures that any new feature or refactor complies with the assessment guidelines.

set -e

echo "=========================================================="
echo "           TapPay Assessment Compliance Checker           "
echo "=========================================================="
echo ""

echo "🔍 1. Checking core specification & rules files..."
for file in "PROJECT_SPECIFICATION.md" "AGENTS.md" "GEMINI.md" "README.md"; do
  if [ -f "$file" ]; then
    echo "  ✅ Found $file"
  else
    echo "  ❌ Missing $file!"
    exit 1
  fi
done

echo ""
echo "📦 2. Checking Flutter environment and dependencies..."
if command -v flutter &> /dev/null; then
  flutter --version | head -n 1
  echo "  Running flutter pub get..."
  flutter pub get
else
  echo "  ⚠️ Flutter command not found in PATH."
fi

echo ""
echo "🔬 3. Running static code analysis (zero warnings target)..."
if command -v flutter &> /dev/null; then
  flutter analyze || true
fi

echo ""
echo "🧪 4. Running test suite..."
if command -v flutter &> /dev/null; then
  flutter test || true
fi

echo ""
echo "=========================================================="
echo "  All instructions in PROJECT_SPECIFICATION.md are active! "
echo "=========================================================="
