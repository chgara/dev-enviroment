#!/bin/sh
set -e
# This script sets up terminal-related dotfiles for this machine.
# It is located in the .config/dev-environment directory, which is a git repository.
# The repository can be cloned to set up the dotfiles on any other machine.

# Detect the package manager

# Detect the package manager
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt install -y"
    echo "Using apt package manager"
elif command -v yay &> /dev/null; then
    PKG_MANAGER="yay"
    INSTALL_CMD="yay -S --noconfirm"
    echo "Using yay package manager"
else
    echo "Neither apt nor yay found. This script supports Arch-based and Debian-based systems only."
    exit 1
fi

# Function to install a package
install_package() {
    package=$1
    if ! command -v $package &> /dev/null; then
        echo "Installing $package..."
        if ! $INSTALL_CMD $package; then
            echo "Failed to install $package with $PKG_MANAGER"
            exit 1
        fi
    else
        echo "$package is already installed"
    fi
}

# Ensure git and curl are installed

if ! command -v git &> /dev/null; then
  echo "git is not installed. Installing git..."
  $INSTALL_CMD git
fi

if ! command -v curl &> /dev/null; then
  echo "curl is not installed. Installing curl..."
  $INSTALL_CMD curl
  fi
  
  # Update package lists if using apt
if [ "$PKG_MANAGER" = "apt" ]; then
  sudo apt update
fi

# Clone the repository
git clone https://github.com/chgara/dev-enviroment ~/.config/dev-environment

cd ~/.config/dev-environment

# Install applications
apps=(curl wget libnotify neofetch zsh ranger git fzf nodejs npm)

# Add distribution-specific packages
if [ "$PKG_MANAGER" = "apt" ]; then
    # Ubuntu/Debian specific package names
    apps+=(autojump)
    # Install pnpm through npm on Ubuntu
    install_package npm && npm install -g pnpm
elif [ "$PKG_MANAGER" = "yay" ]; then
    # Arch specific package names
    apps+=(autojump pnpm)
fi

for app in "${apps[@]}"; do
  install_package "$app"
done

# configure git
git config --global credential.helper store
# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

is_interactive() {
  [ -z "$NONINTERACTIVE" ] && [ -t 0 ] && [ -t 1 ]
}

restore_dir=~/.config/dev-environment/restore
find "$restore_dir" -type f -o -type d | while read file; do
  relative_path="${file#$restore_dir/}"
  target_path="$HOME/$relative_path"
  if [ -e "$target_path" ]; then
      if is_interactive; then
          read -p "$target_path already exists. Do you want to overwrite it? (y/n): " choice
          if [ "$choice" != "y" ]; then
              echo "Skipping $relative_path"
              continue
          fi
      else
          echo "Non-interactive mode: Overwriting $target_path"
      fi 
  fi
  mkdir -p "$(dirname "$target_path")"
  cp -r "$file" "$target_path"
done

# install starship
curl -sS https://starship.rs/install.sh | sh -s -- --yes
# Install neovim config
curl -H 'Cache-Control: no-cache, no-store' -L https://github.com/chgara/nvim-config/raw/master/install.sh | sh

echo "Dotfiles setup complete."
