<<<<<<< HEAD
# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:3.22.2 AS build

WORKDIR /app
COPY . .

# Enable Flutter web
RUN flutter config --enable-web

# Get dependencies
RUN flutter pub get

# Build release version for web
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:stable-alpine
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]


=======
# ---- Build stage: Flutter web ----
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS build
WORKDIR /app

# Enable web & prefetch toolchains
RUN flutter config --enable-web

# Cache deps first (better Docker caching)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy source & resolve again (offline uses cache)
COPY . .
RUN flutter pub get --offline

# Build release (no service worker to simplify proxies)
RUN flutter build web --release --pwa-strategy=none

# ---- Runtime: Nginx ----
FROM nginx:stable-alpine
# Single-page app routing (serve index.html on unknown routes) + wasm mime
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 3000
CMD ["nginx","-g","daemon off;"]
>>>>>>> cc6efde (Flutter web build image + SPA nginx; expose on 8096)
