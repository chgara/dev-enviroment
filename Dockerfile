# Use the official Arch Linux image as the base image
FROM archlinux:latest

# Install packages and yay
RUN pacman -Syu --noconfirm curl git base-devel sudo

# Create a new user 'phobos' with password 'phobos'
RUN useradd -m -G wheel -s /bin/bash phobos

# Allow 'phobos' to use sudo without a password
RUN echo "phobos ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Switch to the 'phobos' user and install yay
USER phobos
WORKDIR /home/phobos
RUN git clone https://aur.archlinux.org/yay-bin.git
RUN cd yay-bin && makepkg -si --noconfirm
RUN rm -rf yay-bin

# Run the curl command with sudo inside the phobos folder
USER root
WORKDIR /home/phobos
RUN curl -L https://github.com/chgara/dev-enviroment/raw/master/install.sh | sh

# Default command to run when the container starts
CMD ["/bin/bash", "-c", "echo 'phobos:$(openssl passwd -1)' | chpasswd && exec /bin/bash"]
