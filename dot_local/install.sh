#!/bin/bash
set -e

# Detect package manager and set update/install commands.
if command -v apt &>/dev/null; then
    PM="apt"
    UPDATE_CMD="sudo apt update"
    INSTALL_CMD="sudo apt install -y"
elif command -v apt-get &>/dev/null; then
    PM="apt-get"
    UPDATE_CMD="sudo apt-get update"
    INSTALL_CMD="sudo apt-get install -y"
elif command -v yum &>/dev/null; then
    PM="yum"
    UPDATE_CMD="sudo yum check-update"
    INSTALL_CMD="sudo yum install -y"
elif command -v dnf &>/dev/null; then
    PM="dnf"
    UPDATE_CMD="sudo dnf check-update"
    INSTALL_CMD="sudo dnf install -y"
elif command -v pacman &>/dev/null; then
    PM="pacman"
    UPDATE_CMD="sudo pacman -Sy"
    INSTALL_CMD="sudo pacman -S --noconfirm"
elif command -v brew &>/dev/null; then
    PM="brew"
    UPDATE_CMD="brew update"
    INSTALL_CMD="brew install"
else
    echo "No supported package manager found. Exiting."
    exit 1
fi

echo "Updating package manager ($PM)..."
eval "$UPDATE_CMD"

# Function: Install Atuin using the official install script.
install_atuin() {
    if ! command -v atuin &>/dev/null; then
        echo "Atuin not found. Installing Atuin via the official installer..."
        curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    else
        echo "Atuin is already installed."
    fi
}

install_aws_cli() {
    # Check if AWS CLI is already installed.
    if command -v aws >/dev/null 2>&1; then
        echo "AWS CLI is already installed."
        return 0
    fi
    # Download the AWS CLI zip file.
    echo "Downloading AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" || {
        echo "Failed to download AWS CLI."
        return 1
    }
    # Unzip the downloaded file.
    echo "Unzipping AWS CLI package..."
    unzip awscliv2.zip -d /usr/local/ || {
        echo "Failed to unzip AWS CLI package."
        return 1
    }
    # Install AWS CLI using sudo.
    echo "Installing AWS CLI..."
    sudo /usr/local/aws/install || {
        echo "AWS CLI installation failed."
        return 1
    }
    echo "AWS CLI installed successfully."
}


# Check and install each tool.
install_atuin
install_aws_cli

echo "Installation complete. All requested packages are installed."
