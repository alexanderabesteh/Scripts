#!/bin/bash

notify-send "Launching Kali-Linux"
virsh --connect qemu:///system start Kali-Linux
virt-viewer --connect qemu:///system Kali-Linux
