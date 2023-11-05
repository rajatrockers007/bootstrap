#!/bin/bash

# Determine the package manager and service management commands
if [[ -x "$(command -v apt)" ]]; then
    # Debian/Ubuntu-based systems
    PACKAGE_MANAGER="apt"
    SERVICE_MANAGER="systemctl"
elif [[ -x "$(command -v pacman)" ]]; then
    # Arch Linux
    PACKAGE_MANAGER="pacman"
    SERVICE_MANAGER="systemctl"
elif [[ -x "$(command -v dnf)" ]]; then
    # Fedora Linux
    PACKAGE_MANAGER="dnf"
    SERVICE_MANAGER="systemctl"
else
    echo "Unsupported distribution. Exiting."
    exit 1
fi

# Install SSH server
sudo $PACKAGE_MANAGER update
sudo $PACKAGE_MANAGER install openssh-server -y

# Enable SSH login (if not already enabled)
sudo $SERVICE_MANAGER enable ssh
sudo $SERVICE_MANAGER start ssh

# Create a directory to store authorized_keys file
mkdir -p ~/.ssh

# Add public SSH keys to the authorized_keys file
cat <<EOL >> ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCD0ILBlvXb9hE76hOXwls9j32UcxlGs9uvCw9ozBalROkvwoYcCpfS4WAb1E+Izu2K70x935coOlRw5iMEdHrojP3tjb6FD4oU/nGkEXyNVjplGuHCSiYMF6xEDANjOvm/affzHv12fMhqVqyQ6fvtNGYCXB2VqBkbHtMr5iQK65lffb6RelCpvcsEZ1S6JNBjwkH+L81ZWTJEMMP/oJelSd+yVLok9HooAXHlQAYA7YFHzfQGHboMl2iuMlQXzwCr9abWDy5WIU8/8R7uXYBBwHP57rE1K0DRrpXePSMufKxN1IxZXA8twFisbt+287lsHllK5DkSS7ypEwvJ6TNuOKgej1zzjUPh8ep5TI+5XBsPQRPoM6HJxpls4fsyzaiPy5neF2UmC9rWSqlkvHLEK1BdrlXohNjnnjPbRBYvb6RTpGrjECxMnXCyEVTVtw4HoHz8s3jNicn/jcNOBH3FYXK7PJxwrYqTwPjYWQ/TPzvDRmCI0AuUUsc742YTAPE= rajat@LXC-Docker
# Add your public SSH keys here, one per line
ssh-rsa YOUR_PUBLIC_KEY_1 comment1
ssh-rsa YOUR_PUBLIC_KEY_2 comment2
# Add more keys as needed
EOL

# Set appropriate permissions for the authorized_keys file
chmod 600 ~/.ssh/authorized_keys

# Restart SSH for changes to take effect
sudo $SERVICE_MANAGER restart ssh

echo "SSH server is installed, login is enabled, and public keys have been added to authorized_keys."