#!/bin/bash

ifconfig wlp2s0 down
macchanger -r wlp2s0
iwconfig wlp2s0 mode managed
ifconfig wlp2s0 up
sv start NetworkManager
