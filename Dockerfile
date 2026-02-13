FROM node:20-alpine

# Install dependencies
RUN apk add --no-cache \
    git \
    curl \
    python3 \
    make \
    g++

# Install OpenClaw globally
RUN npm install -g openclaw@latest

# Create directories for data persistence
RUN mkdir -p /data /config

# Copy OpenClaw configuration (as root, then fix permissions)
COPY --chown=openclaw:openclaw config/openclaw.json /config/openclaw.json

# Set working directory
WORKDIR /app

# Create a non-root user with proper permissions
RUN addgroup -g 1001 -S openclaw && \
    adduser -S -D -H -u 1001 -s /bin/sh -G openclaw openclaw && \
    chown -R openclaw:openclaw /data /config

# Switch to non-root user
USER openclaw

# Environment variables that can be overridden
ENV NODE_ENV=production
ENV OPENCLAW_DATA_DIR=/data
ENV OPENCLAW_CONFIG_DIR=/config
ENV AGENT_WORKSPACE=/data/workspace

# Volume mount points for persistence
VOLUME ["/data", "/config"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "console.log('healthy')" || exit 1

# Default command - starts OpenClaw server
# Override this in docker-compose or Northflank for specific commands
CMD ["openclaw", "start"]
