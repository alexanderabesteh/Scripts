#!/bin/bash

notify-send "Launching Windows 11"
#kitty @ set-background-opacity 1.0
virsh --connect qemu:///system start Windows-11
virt-viewer --connect qemu:///system Windows-11
#virt-manager --connect qemu:///system --show-domain-console Windows-11
