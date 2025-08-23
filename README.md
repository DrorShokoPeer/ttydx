# 🖥️ TTYdx - Modern Terminal Container

A production-ready, secure, and feature-rich terminal container based on ttyd with modern web interface, authentication, and terminal window management.

## ✨ Features

### 🔐 **Security & Authentication**
- Custom login page with session management
- Rate limiting and brute force protection
- JWT-based authentication with secure sessions
- Security headers and HTTPS support
- Non-root container execution
- SSL/TLS termination

### 🖥️ **Terminal Features**
- tmux integration for multiple terminal sessions
- Modern web interface with responsive design
- Multiple shell support (bash, zsh, fish)
- Terminal theming and customization
- Font selection and sizing
- Session management and switching

### 🎨 **Modern UI**
- Dark/light theme toggle
- Mobile-responsive design
- Session management interface
- Real-time terminal switching
- Settings modal for customization
- Professional login interface

### 🏗️ **Production Ready**
- Multi-stage Docker build for optimized images
- Nginx reverse proxy with security headers
- Health checks and comprehensive monitoring
- Structured logging with Winston
- SSL/TLS termination and security
- Container orchestration with Docker Compose

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Git for cloning the repository

### Development Mode
```bash
# Clone and start in development
git clone https://github.com/your-username/ttydx.git
cd ttydx
make dev
```

### Production Mode
```bash
# Build and run in production
make build
make prod
```

### Access Your Terminal
- **HTTP**: http://localhost:8080
- **HTTPS**: https://localhost:8443

### Default Credentials
- **Admin**: `admin` / `admin123`
- **User**: `user` / `user123`

## 🔧 Configuration

### Environment Variables
```env
TZ=UTC                          # Timezone setting
NODE_ENV=production            # Environment mode
SESSION_SECRET=your-secret     # Session encryption key
TTYD_PORT=7681                # TTYd internal port
AUTH_PORT=3000                # Auth server port
```

### Custom SSL Certificates
For production, mount your certificates:
```yaml
volumes:
  - ./ssl/server.crt:/etc/ssl/certs/server.crt:ro
  - ./ssl/server.key:/etc/ssl/private/server.key:ro
```

### Domain Setup for Production
1. Point your domain to the server IP
2. Update SSL certificates in the ssl/ directory
3. Configure environment variables for your domain
4. Use the production profile: `make prod`

## 🛠️ Available Commands

```bash
make build      # Build container image
make dev        # Development mode (with live reload)
make prod       # Production mode
make stop       # Stop all services
make restart    # Quick restart
make logs       # View container logs
make shell      # Access container shell
make status     # Show service status
make clean      # Clean up resources
make backup     # Backup user data
make help       # Show all commands
```

## 📁 Project Structure

```
ttydx/
├── Dockerfile              # Multi-stage container build
├── docker-compose.yml      # Container orchestration
├── Makefile               # Build and deployment commands
├── entrypoint.sh          # Container initialization script
├── auth/                  # Authentication system
│   ├── server.js         # Express.js auth server
│   └── public/           # Web interface assets
│       ├── login.html    # Login page
│       ├── terminal.html # Terminal interface
│       ├── js/          # JavaScript files
│       └── styles/      # CSS stylesheets
├── config/               # Configuration files
│   └── ttyd.conf        # TTYd configuration
├── themes/              # Terminal color themes
│   ├── dark.json       # Dark theme
│   └── light.json      # Light theme
├── scripts/             # Utility scripts
│   └── start-ttyd.sh   # TTYd startup script
├── nginx.conf           # Reverse proxy configuration
├── supervisord.conf     # Process management
├── tmux.conf           # tmux configuration
├── bashrc              # Bash shell configuration
├── zshrc               # Zsh shell configuration
└── README.md           # This documentation
```

## 🔒 Security Features

- **Authentication**: Session-based login with rate limiting
- **Authorization**: Role-based access control
- **Encryption**: HTTPS/WSS for all connections
- **Headers**: Comprehensive security headers via Nginx
- **Isolation**: Non-root container execution
- **Monitoring**: Health checks and structured logging
- **SSL**: Automatic certificate generation or custom certificates

## 🎯 Use Cases

- **Remote Development**: Secure terminal access for development work
- **System Administration**: Web-based server management
- **Education**: Containerized terminal environment for learning
- **DevOps**: Terminal access for CI/CD and deployment tasks
- **Emergency Access**: Browser-based server access when SSH isn't available
- **Team Collaboration**: Shared terminal environment

## 🔄 Updates & Maintenance

```bash
# Update to latest version
make update

# View logs for troubleshooting
make logs

# Backup important data
make backup

# Clean up unused resources
make clean
```

## 📊 Monitoring

### Health Checks
The container includes built-in health checks:
- HTTP endpoint: `/health`
- Container health status via Docker
- Service monitoring via supervisor

### Logs
Access structured logs:
```bash
make logs                          # All service logs
docker-compose exec ttydx htop     # System monitoring
docker-compose exec ttydx tail -f /app/logs/auth.log  # Auth logs
```

## 🌐 Production Deployment

### Basic Production Setup
1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/ttydx.git
   cd ttydx
   ```

2. **Configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

3. **Deploy**:
   ```bash
   make prod
   ```

### Advanced Production with Custom Domain
1. **Set up SSL certificates** (recommended: Let's Encrypt)
2. **Configure reverse proxy** (Nginx/Traefik)
3. **Set environment variables** for your domain
4. **Enable production profile** with Redis and monitoring

### Docker Swarm/Kubernetes
The container is designed to work with orchestration platforms:
- Kubernetes manifests available in `k8s/` directory
- Docker Swarm stack files in `swarm/` directory
- Health checks and rolling updates supported

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit your changes: `git commit -am 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Create a Pull Request

### Development Guidelines
- Follow the existing code style
- Add tests for new features
- Update documentation as needed
- Ensure security best practices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **ttyd**: The excellent terminal-over-WebSocket project by tsl0922
- **tmux**: Terminal multiplexer for session management
- **Alpine Linux**: Minimal and secure base container image
- **Express.js**: Web application framework for authentication
- **Nginx**: High-performance reverse proxy and web server

## 🐛 Troubleshooting

### Common Issues

**Container won't start**:
```bash
# Check logs
make logs

# Verify ports aren't in use
netstat -tlnp | grep :8080
```

**Authentication not working**:
```bash
# Check auth server logs
docker-compose exec ttydx tail -f /app/logs/auth.log

# Verify environment variables
docker-compose exec ttydx env | grep SESSION_SECRET
```

**Terminal connection issues**:
```bash
# Check ttyd logs
docker-compose exec ttydx tail -f /app/logs/ttyd.log

# Test WebSocket connection
curl -H "Upgrade: websocket" -H "Connection: upgrade" http://localhost:8080/ttyd
```

**Missing standard Linux commands (ls, tail, sleep, etc.)**:
The Docker image is based on Alpine Linux, which uses a minimal base image. If you encounter "command not found" errors for standard utilities, this is because the Alpine image includes only essential packages by default. The Dockerfile has been updated to include the necessary packages:

```dockerfile
# These packages provide standard Linux commands
RUN apk update && apk add --no-cache \
    coreutils \      # ls, tail, head, cat, sleep, etc.
    util-linux \     # mount, umount, lsblk, etc.  
    findutils \      # find, xargs, locate
    procps-ng \      # ps, top, free, etc.
    less \           # pager
    tree             # directory tree display
    # Note: grep, sed, awk are provided by BusyBox (already included)
```

To test if all commands are available:
```bash
# Run the command availability test
docker-compose exec ttydx /app/scripts/test-commands.sh

# Or manually test specific commands
docker-compose exec ttydx which ls tail sleep
```

### Getting Help
- Check the [Issues](https://github.com/your-username/ttydx/issues) page
- Review the documentation in the `docs/` directory
- Join our [Discussions](https://github.com/your-username/ttydx/discussions)

---

**Made with ❤️ for the terminal-loving community**# ttydx
# ttydx
# ttydx
