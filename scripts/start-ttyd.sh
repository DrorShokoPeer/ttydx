#!/bin/bash

# TTYd startup script with authentication integration

export TTYD_PORT=7681
export TTYD_INTERFACE=127.0.0.1

# Create log directory
mkdir -p /app/logs

# Set terminal environment
export TERM=xterm-256color
export COLORTERM=truecolor

# Start ttyd with modern configuration
exec ttyd \
    --port $TTYD_PORT \
    --interface $TTYD_INTERFACE \
    --check-origin \
    --max-clients 10 \
    --once \
    --client-option fontSize=14 \
    --client-option fontFamily="'JetBrains Mono', monospace" \
    --client-option theme='{"background": "#1a1a1a", "foreground": "#ffffff"}' \
    --client-option cursorBlink=true \
    --client-option bellStyle=sound \
    tmux new-session -A -s main