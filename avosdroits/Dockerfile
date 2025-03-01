# Stage 1: Build the Flutter web app
FROM debian:latest AS build-env

# Install Flutter dependencies
RUN apt-get update && \
    apt-get install -y curl git unzip && \
    apt-get clean

# Clone the Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Add flutter to path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable Flutter web
RUN flutter channel stable && \
    flutter upgrade && \
    flutter config --enable-web

# Copy the app files
WORKDIR /app
COPY . .

# Get app dependencies
RUN flutter pub get

# Build the app for the web
RUN flutter build web --release

# Stage 2: Create the run-time image
FROM nginx:alpine

# Copy the build output to the nginx public folder
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 