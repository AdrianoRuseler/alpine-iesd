#!/bin/bash

# Variables
GITHUB_URL="https://github.com/AdrianoRuseler/alpine-iesd/tree/main/public-html" 
TEMP_DIR="/tmp/github_download"
DEST_DIR="/var/www/html/iesd"

# If DEST_DIR exists, clear it
if [ -d "$DEST_DIR" ]; then
    echo "Clearing existing $DEST_DIR..."
    sudo rm -rf "$DEST_DIR"/*
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clear destination directory"
        exit 1
    fi
fi

# Create temporary directory
mkdir -p "$TEMP_DIR"

# Check if directory creation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to create temporary directory"
    exit 1
fi

# Download content using wget
echo "Downloading content from GitHub..."
wget -r -np -nH --cut-dirs=3 -P "$TEMP_DIR" "$GITHUB_URL"

# Check if download was successful
if [ $? -ne 0 ]; then
    echo "Error: Download failed"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Create destination directory if it doesn't exist
sudo mkdir -p "$DEST_DIR"

# Check if directory creation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to create destination directory"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Copy files to destination
echo "Copying files to $DEST_DIR..."
sudo cp -r "$TEMP_DIR"/* "$DEST_DIR/"

# Check if copy was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy files"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Download the latest web-selfhosted zip from Ruffle GitHub
echo "Downloading Ruffle web-selfhosted zip..."
curl -s https://api.github.com/repos/ruffle-rs/ruffle/releases | \
    jq -r '.[0].assets[] | select(.name | contains("web-selfhosted.zip")) | .browser_download_url' | \
    xargs curl -L -o "$DEST_DIR/ruffle.zip"

# Check if Ruffle download was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to download Ruffle zip"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Unzip and clean up
echo "Extracting Ruffle files..."
sudo unzip -o "$DEST_DIR/ruffle.zip" -d "$DEST_DIR/ruffle"
sudo rm "$DEST_DIR/ruffle.zip"

# Clean up temporary directory
rm -rf "$TEMP_DIR"

# Set appropriate permissions
echo "Setting permissions..."
sudo chown -R www-data:www-data "$DEST_DIR"
sudo chmod -R 755 "$DEST_DIR"

echo "Download and installation completed successfully!"