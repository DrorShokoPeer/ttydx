#!/bin/bash
set -e

echo "🚀 Starting TTYdx Container..."

# Create necessary directories
mkdir -p /app/logs /etc/ssl/certs /etc/ssl/private /var/run

# Ensure log directory is writable by terminal user (for app-level logs)
chown -R terminal:terminal /app/logs || true

# Generate self-signed SSL certificates if not provided
if [[ ! -f /etc/ssl/certs/server.crt ]]; then
	echo "📜 Generating self-signed SSL certificates..."
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/ssl/private/server.key \
		-out /etc/ssl/certs/server.crt \
		-subj "/C=US/ST=State/L=City/O=TTYdx/CN=localhost"
	
	chmod 600 /etc/ssl/private/server.key
	chmod 644 /etc/ssl/certs/server.crt
fi

# Set up tmux session
echo "🖥️  Setting up tmux environment..."
tmux kill-server 2>/dev/null || true
tmux new-session -d -s main

# Install Oh My Zsh if not present
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	echo "📦 Installing Oh My Zsh..."
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install zsh plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
fi

# Set timezone
if [[ -n "$TZ" ]]; then
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

echo "✅ TTYdx container initialized successfully!"
echo "🌐 Access your terminal at: http://localhost"
echo "🔐 Default credentials: admin/admin123 or user/user123"

# Run the provided command as root (supervisord will manage per-program users)
exec "$@"