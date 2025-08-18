# Multi-stage build for modern ttyd container
FROM node:18-alpine AS auth-builder

WORKDIR /app

# Copy package.json from root
COPY package*.json ./

# Copy auth system files
COPY auth/ ./auth/

# Install dependencies and build auth system
RUN npm install --only=production

# Use pre-built ttyd binary from releases
FROM alpine:3.18 AS ttyd-builder
RUN apk add --no-cache curl && \
    curl -sL https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64 -o /usr/local/bin/ttyd && \
    chmod +x /usr/local/bin/ttyd

FROM alpine:3.18

# Install runtime dependencies
RUN apk add --no-cache \
    bash \
    zsh \
    fish \
    tmux \
    screen \
    nano \
    vim \
    neovim \
    htop \
    git \
    curl \
    wget \
    openssh-client \
    nodejs \
    npm \
    python3 \
    py3-pip \
    nginx \
    supervisor \
    openssl \
    libevent \
    json-c \
    shadow \
    su-exec \
    tzdata \
    ca-certificates

# Copy ttyd binary from builder
COPY --from=ttyd-builder /usr/local/bin/ttyd /usr/local/bin/

# Copy auth system from builder
COPY --from=auth-builder /app /app/auth

# Create non-root user
RUN addgroup -g 1000 terminal && \
    adduser -D -s /bin/zsh -G terminal -u 1000 terminal && \
    echo "terminal:terminal" | chpasswd

# Setup directories
RUN mkdir -p /app/config /app/themes /app/logs /app/scripts /var/log/supervisor && \
    chown -R terminal:terminal /app

# Copy configuration files
COPY config/ /app/config/
COPY themes/ /app/themes/
COPY scripts/ /app/scripts/
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup tmux configuration
COPY tmux.conf /home/terminal/.tmux.conf
RUN chown terminal:terminal /home/terminal/.tmux.conf

# Setup shell configurations
COPY bashrc /home/terminal/.bashrc
COPY zshrc /home/terminal/.zshrc
RUN chown terminal:terminal /home/terminal/.bashrc /home/terminal/.zshrc

# Create startup script directly in container to avoid line ending issues
RUN cat > /app/entrypoint.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Starting TTYdx Container..."

# Create necessary directories
mkdir -p /app/logs /etc/ssl/certs /etc/ssl/private

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

# Switch to terminal user for supervisord and services
exec su-exec terminal "$@"
EOF

RUN chmod +x /app/entrypoint.sh && \
    find /app/scripts -name "*.sh" -exec sed -i 's/\r$//' {} \; && \
    chmod +x /app/scripts/*

# Expose ports
EXPOSE 80 443 7681

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

# Set working directory
WORKDIR /home/terminal

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]