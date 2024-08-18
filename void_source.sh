#!/bin/bash

kitty @ set-background-opacity 0.7

pkg="$(ls ~/.local/pkgs/void-packages/srcpkgs | fzf --prompt="Search Void-src pkgs : " --border=rounded --margin=5% --color='fg:104,fg+:255,pointer:12,hl:255,hl+:12,header:12,prompt:255' --height 100% --reverse --header="                    Templates " --info=hidden --header-first)" 
DIR1=$HOME/.local/pkgs/void-packages/
DIR2=$HOME/.local/pkgs/void-packages/srcpkgs
CHECK="$(xbps-query -s "$pkg" | wc -l)"


if [ "$pkg" ]
then
    if [ "$CHECK" -eq "1" ]
    then
        notify-send "Program already installed"
        sleep 2
        exit
    else
        cd "$DIR1" || exit
        git pull

        cd "$DIR2" || exit
        if [[ -d "$pkg" ]]
        then
            cd "$DIR1" || exit
            notify-send -t 60000 "installing $pkg ..." 
            ./xbps-src pkg "$pkg" && sudo xbps-install -Sy --repository hostdir/binpkgs "$pkg" 
        else
            notify-send "Not found"
            exit
        fi
    fi
else
    exit
fi
notify-send "$pkg installed"

