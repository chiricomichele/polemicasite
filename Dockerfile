# Multi-stage Dockerfile for polemicasite (React + Vite SPA)

# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* yarn.lock* pnpm-lock.yaml* ./

# Install dependencies (try multiple package managers)
# Keep devDependencies available for `tsc -b` during image build.
RUN if [ -f package-lock.json ]; then npm ci --legacy-peer-deps --include=dev || npm install --legacy-peer-deps --include=dev; \
    elif [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
    elif [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile; \
    else npm install --legacy-peer-deps --include=dev; fi

# Copy source code
COPY . .

# Build application
RUN npm run build

# Stage 2: Runtime
FROM nginx:1.27-alpine

# Copy nginx config for SPA (trailing 404 redirects to index.html for client-side routing)
COPY <<EOF /etc/nginx/nginx.conf
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /tmp/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 20M;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_types text/plain text/css text/javascript application/json application/javascript;

    server {
        listen 80;
        server_name _;

        root /usr/share/nginx/html;
        index index.html;

        # Cache static assets (js, css, images) for 1 week
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1w;
            add_header Cache-Control "public, immutable";
        }

        # index.html is not cached (or cache for short period)
        location = /index.html {
            expires 1h;
            add_header Cache-Control "public, no-cache";
        }

        # SPA routing: all non-file requests go to index.html
        location / {
            try_files \$uri \$uri/ /index.html =404;
        }

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "ok\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Copy built artifacts from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Fix permissions (nginx user already exists in nginx:alpine)
RUN chown -R nginx:nginx /usr/share/nginx/html /var/log/nginx /var/cache/nginx

# Switch to non-root user (already created by nginx:alpine image)
USER nginx

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/health || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
