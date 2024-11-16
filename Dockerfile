FROM archlinux/archlinux:base-devel

ARG user=phobos
ARG FORCE_COLOR=1
ARG NONINTERACTIVE=1

# Install packages, yay, and OpenSSH
RUN pacman -Syu --noconfirm git sudo openssh

RUN useradd --system --create-home $user \
    && echo "$user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user \
    && echo "$user:password" | sudo chpasswd

USER $user
WORKDIR /home/$user

# Install yay
RUN git clone https://aur.archlinux.org/yay.git \
    && cd yay \
    && makepkg -sri --needed --noconfirm \
    && cd \
    # Clean up
    && rm -rf .cache yay

# Run the curl command with sudo inside the phobos folder
# RUN curl -s -H 'Cache-Control: no-cache, no-store' -L https://github.com/chgara/dev-enviroment/raw/master/install.sh | NONINTERACTIVE=$NONINTERACTIVE sh
RUN set -x && curl -s -H 'Cache-Control: no-cache, no-store' -L https://github.com/chgara/dev-enviroment/raw/master/install.sh | NONINTERACTIVE=$NONINTERACTIVE sh


# Configure SSH
RUN sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Set a password for the user (change 'password' to your desired password)
RUN echo "$user:password" | sudo chpasswd

# Expose SSH port
EXPOSE 22

USER root
RUN mkdir -p /etc/ssh && chmod 700 /etc/ssh
CMD ["/bin/sh", "-c", "ssh-keygen -A && /usr/sbin/sshd -D"]
