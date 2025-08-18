# Multi-stage build for modern ttyd container
FROM node:18-alpine AS auth-builder

WORKDIR /app

# Copy package.json from root
COPY package*.json ./

# Copy auth system files
COPY auth/ ./auth/

# Install dependencies and build auth system
RUN npm install --only=production

FROM alpine:3.18 AS ttyd-builder

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    cmake \
    git \
    libevent-dev \
    json-c-dev \
    openssl-dev \
    zlib-dev

# Build ttyd from source for latest features
WORKDIR /tmp
RUN git clone https://github.com/tsl0922/ttyd.git && \
    cd ttyd && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install

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

# Create startup script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh /app/scripts/*

# Expose ports
EXPOSE 80 443 7681

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

# Set working directory
WORKDIR /home/terminal

# Run as non-root user
USER terminal

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]