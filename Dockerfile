FROM archlinux/archlinux:base-devel

# Install packages and yay
RUN pacman -Syu --noconfirm git sudo


ARG user=phobos
RUN useradd --system --create-home $user \
  && echo "$user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
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
RUN curl -H 'Cache-Control: no-cache, no-store' -L https://github.com/chgara/dev-enviroment/raw/master/install.sh | sh

# Default command to run when the container starts
CMD ["/bin/bash", "-c", "echo 'phobos:$(openssl passwd -1)' | chpasswd && exec /bin/bash"]
