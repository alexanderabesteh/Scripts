#!/bin/bash

kitty @ set-background-opacity 0.7

# List applications from the system's PATH
apps=$(ls /usr/bin /usr/local/bin /opt/bin 2>/dev/null | sort | uniq)

# Fzf Select
selected_app=$(echo "$apps" | fzf --prompt="Search : " --border=rounded --margin=5% --color='fg:104,fg+:255,pointer:12,hl:255,hl+:12,header:12,prompt:255' --height 100% --reverse --header="        App Launcher " --info=hidden --header-first) 

# If an application was selected, execute it
if [ -n "$selected_app" ]; then
   notify-send "Launching $selected_app ..."
   hyprctl dispatch togglespecialworkspace launcher
  /usr/bin/"$selected_app" &
fi
