Here's a README description for your bash script that explains how to use it:
GitHub Folder Downloader Script
This Bash script downloads the contents of the public-html folder from the GitHub repository AdrianoRuseler/alpine-iesd and the latest Ruffle web-selfhosted package, then installs them into /var/www/html/iesd on an Ubuntu system.
Features

    Downloads the public-html folder from the specified GitHub repository
    Downloads and extracts the latest Ruffle web-selfhosted release
    Places all content in /var/www/html/iesd
    Sets appropriate web server permissions
    Includes dependency checks and error handling

Prerequisites

    Ubuntu operating system
    Root or sudo privileges
    Internet connection

Required Dependencies
The script checks for these automatically:

    wget - For downloading the GitHub repository
    curl - For downloading the Ruffle package
    jq - For parsing GitHub API responses
    unzip - For extracting zip files

Installation

    Save the script as github_downloader.sh:
    bash

    nano github_downloader.sh

    Copy and paste the script content (provided below).
    Make the script executable:
    bash

    chmod +x github_downloader.sh

Usage

    Run the script:
    bash

    ./github_downloader.sh

        You may need to use sudo if not running as root: sudo ./github_downloader.sh
    The script will:
        Check for required dependencies
        Clear the destination directory if it exists
        Download and extract the public-html folder from GitHub
        Download and extract the Ruffle web-selfhosted package
        Set proper permissions for web serving

Output

    Files from public-html will be placed directly in /var/www/html/iesd/
    Ruffle files will be in /var/www/html/iesd/ruffle/
    Temporary files are cleaned up automatically

Troubleshooting

    If a dependency is missing, the script will tell you which one and how to install it (e.g., sudo apt install jq)
    Ensure you have write permissions to /var/www/html/
    Check your internet connection if downloads fail

Script Content
bash

#!/bin/bash

# Variables
REPO_URL="https://github.com/AdrianoRuseler/alpine-iesd/archive/refs/heads/main.zip"
TEMP_DIR="/tmp/github_download"
DEST_DIR="/var/www/html/iesd"

# Function to check if a command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is required but not installed."
        echo "Please install it using: sudo apt install $1"
        exit 1
    fi
}

# Verify required commands
echo "Checking required dependencies..."
check_command "wget"
check_command "curl"
check_command "jq"
check_command "unzip"

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

# Download the repository as a zip
echo "Downloading repository from GitHub..."
wget -O "$TEMP_DIR/repo.zip" "$REPO_URL"

# Check if download was successful
if [ $? -ne 0 ]; then
    echo "Error: Download failed"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Extract the specific folder
echo "Extracting public-html folder..."
unzip -o "$TEMP_DIR/repo.zip" "alpine-iesd-main/public-html/*" -d "$TEMP_DIR"

# Check if unzip was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract files"
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

# Move the public-html contents to destination
echo "Copying files to $DEST_DIR..."
sudo mv "$TEMP_DIR/alpine-iesd-main/public-html"/* "$DEST_DIR/"

# Check if move was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to move files"
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

# Unzip and clean up Ruffle
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

Notes

    The script assumes a web server (like Apache) is installed and uses www-data as the web server user
    Modify REPO_URL if you need content from a different repository or branch
    Run with caution as it clears the destination directory each time