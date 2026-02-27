#!/usr/bin/env bash
set -euo pipefail

USER_NAME="$(whoami)"
HOME_DIR="$HOME"
SCRIPT_DIR="$(pwd)"
BACKUP_DIR="$HOME_DIR/backup_$(date +%Y%m%d_%H%M%S)"

CONFIG_DIRS=(cava hypr waybar fastfetch wofi)

OFFICIAL_PACKAGES=(
  # Core
  nodejs npm zsh git curl rsync cmake
  
  # Hyprland / Wayland Core
  hyprland hyprpaper waybar wofi cliphist wl-clipboard cava
  xdg-desktop-portal-hyprland xdg-user-dirs
  polkit-gnome
  pipewire wireplumber
  grim slurp swappy
  brightnessctl
  network-manager-applet
  bluez bluez-utils blueman
  papirus-icon-theme orbit-wifi
  
  # Qt
  qt6-declarative qt6-svg qt6-quickcontrols2
  qt5-graphicaleffects qt5-quickcontrols2
  
  # Terminal & Dev
  kitty neovim kate python bat btop ncdu fastfetch
  
  # Browsers
  firefox chromium
  
  # Media
  vlc mpv audacity kdenlive obs-studio okular
  
  # System Tools
  gparted timeshift kdeconnect openrgb
  
  # Networking / Apps
  proton-vpn-gtk-app
  lutris qbittorrent
)

AUR_PACKAGES=(
  vesktop-bin
  vscodium-bin
  localsend-bin
  protonup-qt-bin
)

echo "Updating system..."
sudo pacman -Syu --needed

sudo pacman -S --needed "${OFFICIAL_PACKAGES[@]}"

if command -v yay &>/dev/null; then
  yay -S --needed "${AUR_PACKAGES[@]}"
else
  echo "AUR helper not found. Skipping AUR packages."
fi

XDG_MENU_PREFIX=arch- kbuildsycoca6 || true
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
systemctl --user enable wireplumber

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
  echo "Installing Oh My Zsh..."
  if curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | \
     RUNZSH=no CHSH=no sh; then
    echo "Oh My Zsh installed."
  else
    echo "Failed to install Oh My Zsh. Continuing..."
  fi
fi

if [[ -d "$HOME_DIR/pixie-sddm" ]]; then
  cd "$HOME_DIR/pixie-sddm"
  sudo ./install.sh
fi

echo "Done!"
