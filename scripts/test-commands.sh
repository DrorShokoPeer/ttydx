#!/bin/bash

echo "🔍 Testing essential Linux commands availability..."
echo "=================================================="

# Array of essential commands to test
commands=(
    "ls"
    "tail"
    "head"
    "cat"
    "grep"
    "sed"
    "awk"
    "sort"
    "uniq"
    "wc"
    "find"
    "which"
    "whereis"
    "ps"
    "top"
    "free"
    "df"
    "du"
    "hostname"
    "whoami"
    "id"
    "sleep"
    "echo"
    "printf"
    "date"
    "uptime"
    "uname"
    "tree"
    "less"
    "more"
)

# Test each command
missing_commands=()
available_commands=()

for cmd in "${commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        available_commands+=("$cmd")
        echo "✅ $cmd - $(which "$cmd")"
    else
        missing_commands+=("$cmd")
        echo "❌ $cmd - NOT FOUND"
    fi
done

echo ""
echo "=================================================="
echo "📊 Summary:"
echo "Available commands: ${#available_commands[@]}"
echo "Missing commands: ${#missing_commands[@]}"

if [ ${#missing_commands[@]} -gt 0 ]; then
    echo ""
    echo "❌ Missing commands:"
    printf '%s\n' "${missing_commands[@]}"
    exit 1
else
    echo ""
    echo "🎉 All essential commands are available!"
    exit 0
fi