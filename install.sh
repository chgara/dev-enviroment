#!/bin/sh

# This script sets up terminal-related dotfiles for this machine.
# It is located in the .config/dev-environment directory, which is a git repository.
# The repository can be cloned to set up the dotfiles on any other machine.

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi
# Clone the repository
git clone https://your-repo-url.git ~/.config/dev-environment

cd ~/.config/dev-environment

# Install applications
apps=(libnotify neofetch zsh ranger git, autojump, fzf, nodejs, npm, pnpm)
for app in "${apps[@]}"; do
  if ! command -v $app &> /dev/null; then
    echo "Installing $app..."
      if ! sudo pacman -S --noconfirm $app; then
        echo "Package $app not found in pacman, trying yay..."
        if ! yay -S --noconfirm $app; then
          echo "Failed to install $app with both pacman and yay. Continuing..."
        fi
      fi
  else
    echo "$app is already installed"
  fi
done

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

# Install neovim config
sudo curl -L https://github.com/chgara/nvim-config/raw/master/install.sh | sh

echo "Dotfiles setup complete."