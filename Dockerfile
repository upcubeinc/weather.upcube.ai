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


