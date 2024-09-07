apk update

# Start necessary services
apk add alpine-base openrc
rc-update add devfs boot
rc-update add procfs boot
rc-update add sysfs boot

# Change shell
apk add agetty shadow bash
chsh -s /bin/bash root

# Network
apk add wpa_supplicant
rc-update add networking default

# SSH
apk add openssh
rc-update add sshd default

# For timezone
rc-update add local default
apk add tzdata


apk add util-linux nano neofetch git