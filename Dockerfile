FROM node:20-slim

# Set working directory
WORKDIR /app

# Install system dependencies including Python
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    ffmpeg \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY backend/package*.json ./

# Install Node.js dependencies
RUN npm ci --production

# Copy backend files
COPY backend/ ./

# Set up Python virtual environment and install deface
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --no-cache-dir pip==23.0.1 && \
    pip install --no-cache-dir deface

# Create necessary directories
RUN mkdir -p uploads public/processed

# Set environment variables for production
ENV NODE_ENV=production
ENV PORT=3000

# Configure CORS for production
# Note: The CORS origins are already configured in server.js for production

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -f http://localhost:$PORT/api/health || exit 1

# Run the server
CMD ["node", "server.js"] 