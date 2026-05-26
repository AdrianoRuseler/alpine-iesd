# === Builder ===
FROM nginx:alpine AS builder

RUN apk add --no-cache curl jq unzip

RUN mkdir -p /ruffle && \
    curl -s https://api.github.com/repos/ruffle-rs/ruffle/releases/latest | \
    jq -r '.assets[] | select(.name | contains("web-selfhosted.zip")) | .browser_download_url' | \
    xargs curl -L -o /ruffle.zip && \
    unzip /ruffle.zip -d /ruffle && \
    rm /ruffle.zip

# === Final Image ===
FROM nginx:alpine

COPY --from=builder /ruffle /usr/share/nginx/html/ruffle
COPY ./public-html/ /usr/share/nginx/html/

# Copy custom config
COPY nginx.conf /etc/nginx/conf.d/default.conf
