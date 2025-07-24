#!/bin/bash

slurp | grim -g - "$HOME/Documents/Photos/Screenshots/$(date +'%Y-%m-%d_%H:%M:%S').png"
