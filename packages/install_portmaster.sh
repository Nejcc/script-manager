#!/bin/bash

# Function to check if Portmaster is installed
is_installed() {
    systemctl list-units --type=service | grep -q "portmaster.service"
}

# Install or update Portmaster from the official source
install_portmaster() {
    echo "Installing or updating Portmaster from the official source..."
    curl -L https://downloads.safing.io/latest/portmaster/portmaster-installer.sh | bash
}

# Ensure the Portmaster daemon is enabled and running
configure_service() {
    echo "Configuring Portmaster service..."
    sudo systemctl enable portmaster.service
    sudo systemctl start portmaster.service

    if systemctl is-active --quiet portmaster.service; then
        echo "Portmaster daemon is running and enabled at login."
    else
        echo "Failed to start Portmaster daemon. Please check the logs."
    fi
}

# Main script execution
if is_installed; then
    echo "Portmaster is already installed. Reinstalling..."
    install_portmaster
else
    echo "Portmaster is not installed. Installing..."
    install_portmaster
fi

# Configure the service
configure_service

# Verify installation
if is_installed; then
    echo "Portmaster installation and configuration completed successfully."
else
    echo "Portmaster installation failed. Please check for errors."
fi
