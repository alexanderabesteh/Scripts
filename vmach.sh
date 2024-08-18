#!/bin/bash

kitty @ set-background-opacity 0.7

list=$(virsh list --all | cut -b 7- | sed 's/........$//' | tail -n +3 | sed 's/ *$//g')

vms=("Add
$list
Quit")

choice="$(fzf --prompt="Choose a VM : " --border=rounded --margin=5% --color=dark --height 100% --reverse --header=" VM Launcher " --info=hidden --header-first  <<<"${vms[@]}")"

case "$choice" in
    Add)
            choice="$HOME"/.local/instaVM/addvm.sh
            kitty -T addvm -e "$choice"
        ;;
    Quit)
        exit 1
        ;;
    *)
        notify="$(notify-send "v-machine launcher" "launching $choice")"
        $notify
#        choice="$(virsh -q start "$choice") && $(virt-viewer --attach --domain-name "$choice")"
        choice="$(virsh --connect qemu:///system start "$choice") && $(virt-viewer --connect qemu:///system "$choice")"
        ;;
esac
