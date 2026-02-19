#!/bin/bash

username=$(whoami)
wd=$(pwd)

sudo pacman -S --needed nodejs npm electron fastftech hyprland cava waybar wofi cliphist wl-clipboard fastfetch hyprpaper rofi-emoji papirus-icon-theme archlinux-xdg-menu zsh orbit-wifi
XDG_MENU_PREFIX=arch- kbuildsycoca6

rm -rf /home/"$username"/.config/cava/
rm -rf /home/"$username"/.config/hypr/
rm -rf /home/"$username"/.config/waybar/
rm -rf /home/"$username"/.config/fastfetch
rm -rf /home/"$username"/.config/wofi

mkdir /home/"$username"/Pictures/Wallpapers
cp "$wd"/wallpapers/* /home/"$username"/Pictures/Wallpapers

cp "$wd"/config* /home/"$username"/.config
cp "$wd"/local-bin /home/"$username"/.local/bin
cp "$wd"/.zshrc /home/"$username"

git clone https://github.com/TechyTechster/ez-fm.git
cd ez-fm

./install.sh
ez-fm

curl -s https://ohmyposh.dev/install.sh | bash -s
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
