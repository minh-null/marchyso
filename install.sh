#!/usr/bin/env bash
set -euo pipefail

USER_NAME="$(whoami)"
HOME_DIR="$HOME"
SCRIPT_DIR="$(pwd)"
BACKUP_DIR="$HOME_DIR/backup_$(date +%Y%m%d_%H%M%S)"

CONFIG_DIRS=(cava hypr waybar fastfetch wofi)

PACKAGES=(
  # Core
  nodejs npm zsh git curl rsync cmake
  
  # Wayland / Hyprland stack
  hyprland hyprpaper waybar wofi cliphist wl-clipboard cava
  papirus-icon-theme orbit-wifi
  
  # Qt
  qt6-declarative qt6-svg qt6-quickcontrols2
  qt5-graphicaleffects qt5-quickcontrols2
  
  # Terminal & Dev
  kitty neovim kate vscodium-bin python bat btop ncdu fastfetch
  
  # Browsers
  firefox chromium
  
  # Media
  vlc mpv audacity kdenlive obs-studio okular
  
  # System tools
  gparted timeshift kdeconnect openrgb
  
  # Networking
  proton-vpn-gtk-app localsend-bin
  
  # Gaming
  lutris protonup-qt-bin qbittorrent
  
  # Electron apps
  vesktop-bin
)

echo "Updating system..."
sudo pacman -Syu --needed

if command -v yay &>/dev/null; then
  yay -Syu --needed
fi

echo "Installing packages..."
sudo pacman -S --needed "${PACKAGES[@]}"

XDG_MENU_PREFIX=arch- kbuildsycoca6 || true

echo "Creating backup at $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

for dir in "${CONFIG_DIRS[@]}"; do
  if [[ -d "$HOME_DIR/.config/$dir" ]]; then
    cp -r "$HOME_DIR/.config/$dir" "$BACKUP_DIR/"
  fi
done

echo "Replacing configs..."
for dir in "${CONFIG_DIRS[@]}"; do
  rm -rf "$HOME_DIR/.config/$dir"
done

mkdir -p "$HOME_DIR/.config"
cp -r "$SCRIPT_DIR/config/"* "$HOME_DIR/.config/"

mkdir -p "$HOME_DIR/Pictures/Wallpapers"
cp -r "$SCRIPT_DIR/wallpapers/"* "$HOME_DIR/Pictures/Wallpapers/" 2>/dev/null || true


mkdir -p "$HOME_DIR/.local/bin"
cp -r "$SCRIPT_DIR/local-bin/"* "$HOME_DIR/.local/bin/" 2>/dev/null || true
chmod +x $HOME_DIR/.local/bin/emoji-picker
chmod +x $HOME_DIR/.local/bin/screensaver
chmod +x $HOME_DIR/.local/bin/screensaver-bounce
chmod +x $HOME_DIR/.local/bin/wofi-keybinds
chmod +x $HOME_DIR/.local/bin/wofi-launcher
chmod +x $HOME_DIR/.local/bin/wofi-power

install -m 644 "$SCRIPT_DIR/.zshrc" "$HOME_DIR/.zshrc"

mkdir -p "$HOME_DIR/.cache/oh-my-posh/themes"
cp "$SCRIPT_DIR/config/minh_lol_custom_design.omp.json" \
   "$HOME_DIR/.cache/oh-my-posh/themes/"


if ! command -v oh-my-posh &>/dev/null; then
  curl -s https://ohmyposh.dev/install.sh | bash -s
fi


if [[ ! -d "$HOME_DIR/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi


if [[ -d "$HOME_DIR/pixie-sddm" ]]; then
  cd "$HOME_DIR/pixie-sddm"
  sudo ./install.sh
fi

echo "Done!"
