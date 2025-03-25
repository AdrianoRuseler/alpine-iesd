FROM httpd:alpine

# Install necessary tools
RUN apk add --no-cache curl jq

# Copy html content
COPY ./public-html/ /usr/local/apache2/htdocs/

# Create the destination directory
RUN mkdir -p /usr/local/apache2/htdocs/ruffle

# Download the latest web-selfhosted zip
RUN curl -s https://api.github.com/repos/ruffle-rs/ruffle/releases | \
    jq -r '.[0].assets[] | select(.name | contains("web-selfhosted.zip")) | .browser_download_url' | \
    xargs curl -L -o /usr/local/apache2/htdocs/ruffle/ruffle.zip

# Optional: If you need to unzip the file
RUN apk add --no-cache unzip && \
     unzip /usr/local/apache2/htdocs/ruffle/ruffle.zip -d /usr/local/apache2/htdocs/ruffle && \
     rm /usr/local/apache2/htdocs/ruffle/ruffle.zip && \
     apk del unzip
