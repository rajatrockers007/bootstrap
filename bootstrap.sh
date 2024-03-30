#!/bin/bash
groupadd rajat
useradd rajat --create-home --shell /bin/bash -g rajat
echo "rajat ALL=(ALL) NOPASSWD:ALL" |  tee -a /etc/sudoers
gpasswd -a rajat sudo #allowing sudo requires password, and not a good idea for a service account.
mkdir /home/rajat/.ssh
cat <<EOL >> /home/rajat/.ssh/authorized_keys
# Add your public SSH keys here, one per line
ssh-rsa YOUR_PUBLIC_KEY_1 comment1
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCD0ILBlvXb9hE76hOXwls9j32UcxlGs9uvCw9ozBalROkvwoYcCpfS4WAb1E+Izu2K70x935coOlRw5iMEdHrojP3tjb6FD4oU/nGkEXyNVjplGuHCSiYMF6xEDANjOvm/affzHv12fMhqVqyQ6fvtNGYCXB2VqBkbHtMr5iQK65lffb6RelCpvcsEZ1S6JNBjwkH+L81ZWTJEMMP/oJelSd+yVLok9HooAXHlQAYA7YFHzfQGHboMl2iuMlQXzwCr9abWDy5WIU8/8R7uXYBBwHP57rE1K0DRrpXePSMufKxN1IxZXA8twFisbt+287lsHllK5DkSS7ypEwvJ6TNuOKgej1zzjUPh8ep5TI+5XBsPQRPoM6HJxpls4fsyzaiPy5neF2UmC9rWSqlkvHLEK1BdrlXohNjnnjPbRBYvb6RTpGrjECxMnXCyEVTVtw4HoHz8s3jNicn/jcNOBH3FYXK7PJxwrYqTwPjYWQ/TPzvDRmCI0AuUUsc742YTAPE= rajat@LXC-Docker
ssh-rsa YOUR_PUBLIC_KEY_2 comment2
# Add more keys as needed
EOL
chmod 700 /home/rajat/.ssh
chown rajat:rajat /home/rajat -R
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
if [ "$PACKAGE_MANAGER" = "pacman" ]; then
     pacman-key --init 
     pacman-key --populate archlinux 
     pacman-key --refresh-keys -u --keyserver hkps.pool.sks-keyservers.net 
     pacman -S archlinux-keyring
     $PACKAGE_MANAGER -S --noconfirm openssh
     $PACKAGE_MANAGER -S --noconfirm sudo
     $PACKAGE_MANAGER -S --noconfirm glibc
else
     $PACKAGE_MANAGER update -y
     $PACKAGE_MANAGER install openssh-server sudo -y
fi

# Enable SSH login (if not already enabled)
if [ "$PACKAGE_MANAGER" = "pacman" ]; then
     $SERVICE_MANAGER enable sshd
elif [ "$PACKAGE_MANAGER" = "dnf" ]; then
     $SERVICE_MANAGER enable sshd
else
     $SERVICE_MANAGER enable ssh
fi

if [ "$PACKAGE_MANAGER" = "pacman" ]; then
     $SERVICE_MANAGER start sshd
elif [ "$PACKAGE_MANAGER" = "dnf" ]; then
     $SERVICE_MANAGER start sshd
else
     $SERVICE_MANAGER start ssh
fi
# Create a directory to store authorized_keys file
mkdir -p ~/.ssh

# Add public SSH keys to the authorized_keys file
cat <<EOL >> ~/.ssh/authorized_keys
# Add your public SSH keys here, one per line
ssh-rsa YOUR_PUBLIC_KEY_1 comment1
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCD0ILBlvXb9hE76hOXwls9j32UcxlGs9uvCw9ozBalROkvwoYcCpfS4WAb1E+Izu2K70x935coOlRw5iMEdHrojP3tjb6FD4oU/nGkEXyNVjplGuHCSiYMF6xEDANjOvm/affzHv12fMhqVqyQ6fvtNGYCXB2VqBkbHtMr5iQK65lffb6RelCpvcsEZ1S6JNBjwkH+L81ZWTJEMMP/oJelSd+yVLok9HooAXHlQAYA7YFHzfQGHboMl2iuMlQXzwCr9abWDy5WIU8/8R7uXYBBwHP57rE1K0DRrpXePSMufKxN1IxZXA8twFisbt+287lsHllK5DkSS7ypEwvJ6TNuOKgej1zzjUPh8ep5TI+5XBsPQRPoM6HJxpls4fsyzaiPy5neF2UmC9rWSqlkvHLEK1BdrlXohNjnnjPbRBYvb6RTpGrjECxMnXCyEVTVtw4HoHz8s3jNicn/jcNOBH3FYXK7PJxwrYqTwPjYWQ/TPzvDRmCI0AuUUsc742YTAPE= rajat@LXC-Docker
ssh-rsa YOUR_PUBLIC_KEY_2 comment2
# Add more keys as needed
EOL

# Set appropriate permissions for the authorized_keys file
chmod 600 ~/.ssh/authorized_keys

# Restart SSH for changes to take effect
# Enable SSH login (if not already enabled)
if [ "$PACKAGE_MANAGER" = "pacman" ]; then
     $SERVICE_MANAGER restart sshd
elif [ "$PACKAGE_MANAGER" = "dnf" ]; then
     $SERVICE_MANAGER restart sshd
else
     $SERVICE_MANAGER restart ssh
fi



echo "SSH server is installed, login is enabled, and public keys have been added to authorized_keys."
passwd rajat
