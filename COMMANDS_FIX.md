# Missing Commands Fix for TTYdx

## Problem Description

The TTYdx Docker image was built using Alpine Linux as the base image, which is extremely minimal and doesn't include standard Linux commands like `tail`, `ls`, `sleep`, and others in their usual locations. This caused "command not found" errors when users tried to use basic Unix utilities within the container.

## Root Cause

Alpine Linux uses BusyBox for many basic utilities, but it doesn't include the full GNU coreutils package by default. The original Dockerfile was missing several essential packages that provide standard Linux commands.

### Package Issues Resolved

1. **Missing coreutils**: Commands like `ls`, `tail`, `head`, `cat`, `sleep` were not available
2. **Incorrect package names**: Used `procps` instead of `procps-ng` (Alpine-specific naming)
3. **Redundant packages**: Removed `grep`, `sed`, `awk` as they're provided by BusyBox
4. **Non-existent packages**: Removed `busybox-extras` which doesn't exist in Alpine 3.18

## Solution

### 1. Updated Dockerfile

Added the following packages to the `apk add` command in the Dockerfile:

```dockerfile
# Install runtime dependencies
RUN apk update && apk add --no-cache \
    # ... existing packages ...
    coreutils \      # ls, tail, head, cat, sleep, etc.
    util-linux \     # mount, umount, lsblk, etc.  
    findutils \      # find, xargs, locate
    procps-ng \      # ps, top, free, etc.
    less \           # pager
    tree             # directory tree display
    # Note: grep, sed, awk are provided by BusyBox (already included)
```

### 2. Created Test Script

Added `/app/scripts/test-commands.sh` to verify that all essential commands are available:

- Tests 30+ common Linux commands
- Reports which commands are available and their locations
- Provides clear pass/fail status
- Can be run via `make test-commands`

### 3. Updated Documentation

- Added troubleshooting section to README.md
- Explained the Alpine Linux minimal base image issue
- Provided commands to test and verify the fix
- Added Makefile target for easy testing

### 4. Makefile Integration

Added new target:
```makefile
test-commands:
    @echo "🔍 Testing command availability in container..."
    docker-compose exec ttydx /app/scripts/test-commands.sh
```

## Commands Now Available

The following standard Linux commands are now available in the container:

- **File operations**: `ls`, `cat`, `tail`, `head`, `find`, `tree`
- **Text processing**: `grep`, `sed`, `awk`, `sort`, `uniq`, `wc`
- **System info**: `ps`, `top`, `free`, `df`, `du`, `hostname`, `uname`
- **Utilities**: `sleep`, `which`, `whereis`, `less`, `more`
- **And many more...**

## Testing the Fix

After rebuilding the container, you can test the fix using:

```bash
# Build and start the container
make dev

# Test command availability
make test-commands

# Or manually test specific commands
docker-compose exec ttydx which ls tail sleep
docker-compose exec ttydx ls -la /bin /usr/bin | grep -E "(ls|tail|sleep)"
```

## Impact

- ✅ All standard Linux commands are now available
- ✅ Users can use familiar Unix utilities within the terminal
- ✅ Container maintains minimal size while providing essential tools
- ✅ No breaking changes to existing functionality
- ✅ Comprehensive testing and documentation added

## Future Considerations

- The added packages increase the image size slightly but provide essential functionality
- All packages are production-ready and maintained by the Alpine Linux team
- Regular updates to the base Alpine image will keep security patches current
- Additional packages can be added as needed following the same pattern