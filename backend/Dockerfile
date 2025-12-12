# ============================================
# Stage 1: Builder
# ============================================
FROM node:20-bullseye AS builder

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies (including devDependencies for build)
RUN npm install && npm cache clean --force

# Copy source code
COPY . .

# Build TypeScript application
RUN npm run build

# ============================================
# Stage 2: Production
# ============================================
FROM node:20-bullseye-slim

# Install system dependencies for Puppeteer and PostgreSQL client
RUN apt-get update \
  && apt-get install -y \
  wget \
  gnupg \
  ca-certificates \
  postgresql-client \
  netcat \
  --no-install-recommends \
  # Add Google Chrome repository
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  # Install Chrome and fonts
  && apt-get install -y \
  google-chrome-stable \
  fonts-ipafont-gothic \
  fonts-wqy-zenhei \
  fonts-thai-tlwg \
  fonts-kacst \
  fonts-freefont-ttf \
  libxss1 \
  --no-install-recommends \
  # Cleanup
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# Create non-root user
RUN groupadd -r whaticket && useradd -r -g whaticket -m -d /home/whaticket whaticket

# Set working directory
ENV WORKDIR /usr/src/app
WORKDIR $WORKDIR

# Copy built application from builder
COPY --from=builder --chown=whaticket:whaticket /usr/src/app/dist ./dist
COPY --from=builder --chown=whaticket:whaticket /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=whaticket:whaticket /usr/src/app/package*.json ./

# Copy additional required files
COPY --chown=whaticket:whaticket .sequelizerc ./
COPY --chown=whaticket:whaticket src/database ./src/database

# Copy entrypoint and healthcheck scripts
COPY --chown=whaticket:whaticket entrypoint.sh /usr/local/bin/
COPY --chown=whaticket:whaticket healthcheck.js /usr/local/bin/

# Make entrypoint executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create necessary directories with proper permissions
RUN mkdir -p /usr/src/app/public \
  && mkdir -p /usr/src/app/.wwebjs_auth \
  && chown -R whaticket:whaticket /usr/src/app

# Switch to non-root user
USER whaticket

# Environment variables
ENV NODE_ENV=production
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD node /usr/local/bin/healthcheck.js || exit 1

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start application
CMD ["npm", "start"]
