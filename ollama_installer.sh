#!/bin/bash

# Define a function to print the help message
print_help() {
    echo "Usage: $0 [-v <version>]"
    echo " -v, --version <version> Specify the version of Ollama to install or update to."
    echo "Example: $0 -v 0.3.14"
    echo " -h, --help Display this help message"
}

# Check if the version argument is provided
if [ "$1" = "-v" -o "$1" = "--version" ]; then
    # Check if the version number is provided
    if [ $# -lt 2 ]; then
        echo "Please provide the version number."
        print_help
        exit 1
    fi
    OLLAMA_VERSION=${2#v}
else
    # Make the help argument (-h or --help) print the help message
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        print_help
        exit 0
    fi
fi

# Get the latest release from the Ollama GitHub repository
OLLAMA_LATEST_VERSION=$(curl -s https://api.github.com/repos/ollama/ollama/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
OLLAMA_LATEST_VERSION=${OLLAMA_LATEST_VERSION#v}

# Initialize variables to track the installation type and action
action_type="update to"
is_first_install=0
is_systemd=0

# Check if the command ollama is available
if ! command -v ollama &> /dev/null; then
    # If ollama is not available, it's a new installation
    action_type="install of"
    is_first_install=1
    # Prompt the user to confirm the installation
    read -p "Ollama installation not found. Press [Enter] key to install now... " -r user_response
    if [ -n "$user_response" ]; then
        echo "Exiting..."
        exit 0
    fi
else
    # Get the current version of ollama
    OLLAMA_CURRENT_VERSION=$(echo $(ollama --version) | awk '{print $4}')
    echo "Installed version $OLLAMA_CURRENT_VERSION"
fi

# Display the latest version available
echo "Latest version $OLLAMA_LATEST_VERSION"

# Check if OLLAMA_VERSION is set at all
if [ -z "$OLLAMA_VERSION" ]; then
    # If OLLAMA_VERSION is not set, prompt the user to install the latest version
    user_prompt="Install latest version : $OLLAMA_LATEST_VERSION ? (y/n) : "
    installation_version=$OLLAMA_LATEST_VERSION
else
    # If OLLAMA_VERSION is set, prompt the user to install the specific version
    user_prompt="Install specific version : $OLLAMA_VERSION ? (y/n) : "
    installation_version=$OLLAMA_VERSION
fi

# Prompt the user to confirm the installation
read -p "$user_prompt" -r user_response
if [ -z "$user_response" ] || [[ "$user_response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    # Set OLLAMA_VERSION to the target version and export it
    OLLAMA_VERSION=$installation_version
    export OLLAMA_VERSION
    echo "Starting ollama $action_type version $OLLAMA_VERSION ..."
    
    # If it's not a new installation
    if [ $is_first_install -eq 0 ]; then
        # Check if os has systemd
        if ! command -v systemctl &> /dev/null; then
            echo "Systemd not found."
        else 
            # Set is_systemd to 1
            is_systemd=1
            # Find the current override config
            if [ -f /etc/systemd/system/ollama.service.d/override.conf ]; then
                # Copy it to the current user's home under the name of ollama.service.override.conf
                cp /etc/systemd/system/ollama.service.d/override.conf $HOME/ollama.service.override.conf
                echo "Saved override config to $HOME/ollama.service.override.conf"
            else
                # No override config found
                echo "No systemd override config found. Continuing..."
            fi
        fi
        
    fi

    # Install or update ollama
    if [ $is_first_install -eq 1 ]; then
        echo "Installing Ollama..."
    else
        echo "Updating Ollama..."
    fi
    
    curl -fsSL https://ollama.com/install.sh | OLLAMA_VERSION=$OLLAMA_VERSION sh

    # If it's not a new installation and an override config is found
    if [ $is_first_install -eq 0 ] && [ $is_systemd -eq 1 ] && [ -f $HOME/ollama.service.override.conf ]; then
        echo "Restoring override config from $HOME/ollama.service.override.conf"
        sudo cp $HOME/ollama.service.override.conf /etc/systemd/system/ollama.service.d/override.conf
        echo "Reloading systemd and restarting ollama service..."
        sudo systemctl daemon-reload
        sudo systemctl restart ollama
    fi
        echo "Done."
        echo "Checking current version..."
        sleep 10
        ollama --version
else
    echo "Exiting..."
    exit 0
fi
