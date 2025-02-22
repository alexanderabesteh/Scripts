#!/bin/bash

sv stop NetworkManager
ifconfig wlp2s0 down
macchanger -r wlp2s0
iwconfig wlp2s0 mode monitor
ifconfig wlp2s0 up
