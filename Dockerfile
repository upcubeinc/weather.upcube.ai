# ---- Build stage: install Flutter + build web ----
FROM debian:bookworm-slim AS build

# Base deps for Flutter/Dart & pub (git/unzip/ca-certs/etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl unzip xz-utils zip ca-certificates libglu1-mesa \
  && rm -rf /var/lib/apt/lists/*

# Install Flutter (stable)
RUN git clone -b stable https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-warm Flutter & enable web
RUN flutter --version && flutter config --enable-web && flutter doctor -v

WORKDIR /app

# Cache pub dependencies first
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get -v

# Now copy the rest of the source & resolve again (uses cache)
COPY . .
RUN flutter pub get -v

# Build release web bundle (no service worker to simplify proxies)
RUN flutter clean \
 && flutter precache --web \
 && flutter pub get -v \
 && flutter build web --release --web-renderer=html --no-tree-shake-icons -v --pwa-strategy=none

# ---- Runtime stage: Nginx to serve the SPA ----
FROM nginx:stable-alpine
# SPA routing + wasm mime
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 3000
CMD ["nginx","-g","daemon off;"]
