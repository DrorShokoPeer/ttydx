# TTYdx Container Management

.PHONY: build run stop clean logs dev prod test-commands

# Default target
all: build

# Build the container
build:
	@echo "🏗️  Building TTYdx container..."
	docker build -t ttydx:latest .

# Run in development mode
dev:
	@echo "🚀 Starting TTYdx in development mode..."
	docker-compose up --build

# Run in production mode
prod:
	@echo "🚀 Starting TTYdx in production mode..."
	docker-compose --profile production up -d

# Stop all services
stop:
	@echo "🛑 Stopping TTYdx services..."
	docker-compose down

# View logs
logs:
	docker-compose logs -f

# Clean up
clean:
	@echo "🧹 Cleaning up TTYdx resources..."
	docker-compose down -v
	docker rmi ttydx:latest 2>/dev/null || true
	docker system prune -f

# Quick restart
restart: stop prod

# Shell into running container
shell:
	docker-compose exec ttydx /bin/zsh

# Show status
status:
	@echo "📊 TTYdx Status:"
	@docker-compose ps
	@echo "\n🌐 Access URLs:"
	@echo "  • HTTP:  http://localhost:8080"
	@echo "  • HTTPS: https://localhost:8443"

# Update and rebuild
update:
	@echo "📥 Updating TTYdx..."
	git pull
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d

# Backup user data
backup:
	@echo "💾 Creating backup..."
	docker run --rm -v ttydx_ttydx_data:/data -v $(PWD):/backup alpine tar czf /backup/ttydx-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz -C /data .

# Test command availability
test-commands:
	@echo "🔍 Testing command availability in container..."
	docker-compose exec ttydx /app/scripts/test-commands.sh

# Help
help:
	@echo "TTYdx Container Commands:"
	@echo "  build    - Build the container image"
	@echo "  dev      - Run in development mode"
	@echo "  prod     - Run in production mode"
	@echo "  stop     - Stop all services"
	@echo "  restart  - Quick restart"
	@echo "  logs     - View logs"
	@echo "  shell    - Access container shell"
	@echo "  status   - Show service status"
	@echo "  clean    - Clean up resources"
	@echo "  backup   - Backup user data"
	@echo "  test-commands - Test command availability"
	@echo "  help     - Show this help"