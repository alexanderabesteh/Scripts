#!/bin/bash

kitty @ set-background-opacity 0.7

# Prettier Names
custom_names=(
  "Neovim init.lua"
  "Hyprland Config"
  "Kitty Config"
  "Waybar Config"
  "Waybar Style CSS"
  "Fish Config"
  "Bash Config"
)

# Paths for each name
file_paths=(
  "$HOME/.config/nvim/init.lua"
  "$HOME/.config/hypr/hyprland.conf"
  "$HOME/.config/kitty/kitty.conf"
  "$HOME/.config/waybar/config"
  "$HOME/.config/waybar/style.css"
  "$HOME/.config/fish/config.fish"
  "$HOME/.bashrc"
)

# Fzf Select
selected_name=$(printf '%s\n' "${custom_names[@]}" | fzf --prompt="Search for a config : " --border=rounded --margin=5% --color='fg:104,fg+:255,pointer:12,hl:255,hl+:12,header:12,prompt:255' --height 100% --reverse) 

# Check if a custom name was selected
if [[ -n $selected_name ]]; then
  # Find the index of the selected custom name
  index=$(printf '%s\n' "${custom_names[@]}" | grep -n "^$selected_name$" | cut -d: -f1)
  
  # Get the corresponding file path
  selected_file=${file_paths[$((index - 1))]}
  
  # Check if the selected file requires superuser privileges
  if [[ -w $selected_file ]]; then
    # Open the selected file in Neovim as a regular user
    notify-send "Opening $selected_file ..."
    nvim "$selected_file"
  else
    # Open the selected file in Neovim with superuser privileges
    notify-send "Opening $selected_file ..."
    sudo -E nvim "$selected_file"
  fi
else
  notify-send "No File Selected"
fi
hyprctl dispatch killactive
