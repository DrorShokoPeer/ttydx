# ---------- build auth (node-only) ----------
FROM node:20-alpine AS auth-builder
WORKDIR /app/auth
COPY auth/package*.json ./
RUN npm ci --omit=dev
COPY auth/ .
# if you have a build step, add: RUN npm run build

# ---------- final image ----------
FROM alpine:3.20

# base runtime
RUN apk add --no-cache \
  bash zsh fish tmux screen nano vim neovim htop git curl wget \
  openssh-client python3 py3-pip nginx supervisor openssl libevent json-c \
  shadow su-exec tzdata ca-certificates ttyd

# non-root user
RUN addgroup -g 1000 terminal && \
    adduser -D -s /bin/zsh -G terminal -u 1000 terminal && \
    echo "terminal:terminal" | chpasswd

# app dirs
RUN mkdir -p /app/config /app/themes /app/logs /app/scripts /var/log/supervisor && \
    chown -R terminal:terminal /app

# bring in auth bundle built above
COPY --from=auth-builder /app/auth /app/auth

# configs and scripts from repo
COPY config/ /app/config/
COPY themes/ /app/themes/
COPY scripts/ /app/scripts/
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY tmux.conf /home/terminal/.tmux.conf
COPY bashrc /home/terminal/.bashrc
COPY zshrc /home/terminal/.zshrc
RUN chown terminal:terminal /home/terminal/.tmux.conf /home/terminal/.bashrc /home/terminal/.zshrc

# sanitize line endings + perms + self-signed TLS
RUN find /app/scripts -name "*.sh" -exec sed -i 's/\r$//' {} \; && \
    chmod +x /app/scripts/* && \
    mkdir -p /etc/ssl/certs /etc/ssl/private && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/ssl/private/server.key \
      -out /etc/ssl/certs/server.crt \
      -subj "/C=US/ST=State/L=City/O=TTYdx/CN=localhost" && \
    chmod 600 /etc/ssl/private/server.key && \
    chmod 644 /etc/ssl/certs/server.crt

# entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# defaults
ENV TTYD_PORT=7681
WORKDIR /home/terminal
USER terminal

EXPOSE 80 443 7681
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://127.0.0.1:80/health || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
