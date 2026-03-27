# BUILD
FROM node:20-slim AS builder
WORKDIR /app
ENV NODE_ENV=development
COPY package*.json ./
RUN npm ci --legacy-peer-deps
COPY . .
RUN npm run build

# RUNTIME
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

