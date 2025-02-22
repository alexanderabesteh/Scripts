#!/bin/bash

notify-send "Launching iMac-Pro"
virsh --connect qemu:///system start macOS
virt-viewer --connect qemu:///system macOS
