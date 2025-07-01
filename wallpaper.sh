#!/bin/bash

# Configuration
WALLPAPER_DIR="$HOME/Documents/Assets/Wallpapers"
TRANSITION_TYPE="outer"
INTERVAL=300  # 5 minutes
LOCK_FILE="/tmp/hypr_wallpaper_switcher.lock"
INDEX_FILE="$HOME/.cache/wallpaper_index.txt"
LOG_FILE="$HOME/.cache/hypr_wallpaper_switcher.log"

# Monitor configuration (run 'hyprctl monitors' to check your monitor)
MONITOR="EDP-1"  # Change this to your monitor name

# Initialize logging
init_logging() {
    mkdir -p "$(dirname "$LOG_FILE")"
    exec 3>>"$LOG_FILE"
    echo "--- Session started $(date) ---" >&3
}

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >&3
}

# Cleanup function
cleanup() {
    log "Cleaning up..."
    pkill -f "mpvpaper -o" || { log "Failed to kill mpvpaper"; true; }
    rm -f "$LOCK_FILE" || { log "Failed to remove lock file"; true; }
    exec 3>&-
    exit
}
trap cleanup EXIT INT TERM

# Check dependencies
check_dependencies() {
    local missing=()

    if ! command -v swww >/dev/null; then
        missing+=("swww")
    fi

    if ! command -v mpvpaper >/dev/null; then
        missing+=("mpvpaper")
    fi

    if ! command -v hyprctl >/dev/null; then
        missing+=("hyprctl")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        log "Missing dependencies: ${missing[*]}"
        echo "ERROR: Missing required packages: ${missing[*]}" >&2
        echo "Install with: sudo xbps-install ${missing[*]}" >&2
        exit 1
    fi
}

# Get current monitor if not configured
detect_monitor() {
    if [ -z "$MONITOR" ] || [ "$MONITOR" = "auto" ]; then
        MONITOR=$(hyprctl monitors -j | jq -r '.[0].name')
        if [ -z "$MONITOR" ]; then
            log "Failed to detect monitor, using default DP-1"
            MONITOR="DP-1"
        fi
    fi
}

# Initialize swww if not running
init_swww() {
    if ! pgrep swww >/dev/null; then
        log "Initializing swww..."
        swww kill >/dev/null 2>&1
        sleep 0.5
        if ! swww init; then
            log "Failed to initialize swww"
            exit 1
        fi
        sleep 1
    fi
}

# Get all supported wallpapers in a reliable way
get_wallpapers() {
    local wallpapers=()
    while IFS= read -r -d $'\0' file; do
        wallpapers+=("$file")
        done < <(find "$WALLPAPER_DIR" -type f \( \
            -iname "*.jpg" -o \
            -iname "*.png" -o \
            -iname "*.jpeg" -o \
            -iname "*.mp4" -o \
        -iname "*.webm" \) -print0 | sort -z)

    # Verify we found wallpapers
    if [ ${#wallpapers[@]} -eq 0 ]; then
        log "No wallpapers found in $WALLPAPER_DIR"
        echo "ERROR: No wallpapers found in $WALLPAPER_DIR" >&2
        exit 1
    fi

    printf "%s\n" "${wallpapers[@]}"
}

# Set wallpaper based on file type
set_wallpaper() {
    local wallpaper="$1"
    local extension="${wallpaper##*.}"

    log "Attempting to set wallpaper: $wallpaper"

    # Kill any existing mpvpaper instance
    pkill -f "mpvpaper -o" || { log "No existing mpvpaper to kill"; true; }

    case "${extension,,}" in
        mp4|webm)
            log "Setting live wallpaper (${extension}): $wallpaper"
            if ! mpvpaper -o "--loop --no-audio" '*' "$wallpaper" &>> "$LOG_FILE"; then
                log "Failed to set live wallpaper"
                return 1
            fi
            ;;
        *)
            log "Setting static wallpaper (${extension}): $wallpaper"
            if ! swww img "$wallpaper" --transition-type="$TRANSITION_TYPE" &>> "$LOG_FILE"; then
                log "Failed to set static wallpaper"
                return 1
            fi
            ;;
    esac

    # Update last set wallpaper
    echo "$wallpaper" > "${INDEX_FILE%.*}.last"
    return 0
}

# Main wallpaper switching function
switch_wallpaper() {
    # Read wallpapers into array
    local wallpapers=()
    readarray -t wallpapers < <(get_wallpapers)
    local total_wallpapers=${#wallpapers[@]}

    # Get current index
    mkdir -p "$(dirname "$INDEX_FILE")"
    local current_index=$(cat "$INDEX_FILE" 2>/dev/null || echo "0")

    # Validate index
    if [[ ! "$current_index" =~ ^[0-9]+$ ]] || [ "$current_index" -ge "$total_wallpapers" ]; then
        current_index=0
    fi

    # Set wallpaper based on type
    if ! set_wallpaper "${wallpapers[$current_index]}"; then
        log "Wallpaper failed, trying next one"
        current_index=$(( (current_index + 1) % total_wallpapers ))
    fi

    # Update index
    current_index=$(( (current_index + 1) % total_wallpapers ))
    echo "$current_index" > "$INDEX_FILE"
    log "Next index will be: $current_index"

    return 0
}

# Handle manual vs automatic mode
main() {
    init_logging
    check_dependencies
    detect_monitor
    init_swww

    case "$1" in
        --daemon)
            # Daemon mode - automatic cycling
            if [ -f "$LOCK_FILE" ]; then
                log "Daemon already running!"
                exit 1
            fi
            touch "$LOCK_FILE"

            log "Starting wallpaper daemon"
            while true; do
                switch_wallpaper
                sleep "$INTERVAL"
            done
            ;;
        --set-last)
            # Set last used wallpaper
            if [ -f "${INDEX_FILE%.*}.last" ]; then
                set_wallpaper "$(cat "${INDEX_FILE%.*}.last")"
            else
                switch_wallpaper
            fi
            ;;
        *)
            # Manual mode - single switch
            if [ -f "$LOCK_FILE" ]; then
                log "Manual switch triggered (daemon running)"
                switch_wallpaper
            else
                log "Manual switch triggered (no daemon)"
                switch_wallpaper
            fi
            ;;
    esac
}

main "$@"
