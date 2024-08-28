# Use the official Arch Linux image as the base image
FROM archlinux:latest

# Update the package database and install curl
RUN pacman -Syu --noconfirm curl git

RUN set -e && curl -L https://github.com/chgara/dev-enviroment/raw/master/install.sh | sh

# Set the working directory
WORKDIR /workspace

# Default command to run when the container starts
CMD ["/bin/bash"]
