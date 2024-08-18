#!/bin/bash

kitty @ set-background-opacity 0.7

# Options
options=(
  "Shutdown"
  "Reboot"
)

# Fzf Select
selected_option=$(printf '%s\n' "${options[@]}" | fzf --border=rounded --margin=5% --color='fg:104,fg+:255,pointer:12,hl:255,hl+:12,header:12,prompt:255' --height 100% --reverse --header="eXit" --info=hidden --header-first) 

# Shutdown or Reboot
case $selected_option in
  "Shutdown")
    notify-send "Shutting Down ..."
    sudo shutdown -h now
    ;;
  "Reboot")
    notify-send "Rebooting ..."
    sudo reboot
    ;;
  *)
    notify-send "No Option Selected"
    ;;
esac
