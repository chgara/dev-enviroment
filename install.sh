#!/bin/sh
set -e
# This script sets up terminal-related dotfiles for this machine.
# It is located in the .config/dev-environment directory, which is a git repository.
# The repository can be cloned to set up the dotfiles on any other machine.

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Ensure yay, git, and curl are installed
if ! command -v yay &> /dev/null; then
  echo "yay is not installed. Please install yay and rerun the script."
  exit 1
fi

if ! command -v git &> /dev/null; then
  echo "git is not installed. Please install git and rerun the script."
  yay -S --noconfirm git
fi
fi

if ! command -v curl &> /dev/null; then
  echo "curl is not installed. Please install curl and rerun the script."
  yay -S --noconfirm curl
fi

# Clone the repository
git clone https://github.com/chgara/dev-enviroment ~/.config/dev-environment

cd ~/.config/dev-environment

# Install applications
apps=(curl wget libnotify neofetch zsh ranger git autojump fzf nodejs npm pnpm)
for app in "${apps[@]}"; do
  if ! command -v $app &> /dev/null; then
    echo "Installing $app..."
    if ! yay -S --noconfirm $app; then
      echo "Failed to install $app with yay."
      exit 1
    fi
  else
    echo "$app is already installed"
  fi
done

# configure git
git config --global credential.helper store
# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

restore_dir=~/.config/dev-environment/restore
find "$restore_dir" -type f -o -type d | while read file; do
  relative_path="${file#$restore_dir/}"
  target_path="$HOME/$relative_path"
  if [ -e "$target_path" ]; then
    read -p "$target_path already exists. Do you want to overwrite it? (y/n): " choice
    if [ "$choice" != "y" ]; then
      echo "Skipping $relative_path"
      continue
    fi
  fi
  mkdir -p "$(dirname "$target_path")"
  cp -r "$file" "$target_path"
done

# install starship
curl -sS https://starship.rs/install.sh | sudo sh
# Install neovim config
curl -L https://github.com/chgara/nvim-config/raw/master/install.sh | sh

echo "Dotfiles setup complete."
