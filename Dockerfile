# ---- Build stage: Flutter web ----
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS build
WORKDIR /app

# Enable Flutter web
RUN flutter config --enable-web

# Cache dependencies first for faster rebuilds
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy source & resolve again (uses cache)
COPY . .
RUN flutter pub get

# Build release (no PWA service worker to simplify proxying)
RUN flutter build web --release --pwa-strategy=none

# ---- Runtime: Nginx ----
FROM nginx:stable-alpine
# SPA routing + wasm mime
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 3000
CMD ["nginx","-g","daemon off;"]
