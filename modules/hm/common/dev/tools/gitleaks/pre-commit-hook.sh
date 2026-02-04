#!/usr/bin/env bash
echo "🔍 Running Gitleaks scan..."

# Debug: Show staged files
echo "Staged files to be scanned:"

# Check if gitleaks is installed
if ! command -v gitleaks &> /dev/null; then
    echo "⚠️  Gitleaks not installed. Skipping scan."
    echo "   Install with: brew install gitleaks or go install github.com/gitleaks/gitleaks/v8@latest"
    exit 0
fi

# Use custom config if it exists
CONFIG_FLAG=""
CONFIG_FILE="$HOME/.git-config/.gitleaks.toml"
if [ -f "$CONFIG_FILE" ]; then
    CONFIG_FLAG="--config $CONFIG_FILE"
fi

# Run gitleaks on staged changes
if gitleaks detect --source . --verbose $CONFIG_FLAG; then
    echo "✅ Gitleaks scan passed - no secrets detected"
    exit 0
else
    echo "❌ Gitleaks found secrets in your changes!"
    echo "   Please remove the detected secrets before committing."
    echo "   To skip this check (not recommended), use: git commit --no-verify"
    exit 1
fi
