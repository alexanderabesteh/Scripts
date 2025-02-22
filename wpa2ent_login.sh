#!/bin/bash

read -rep $'Connection Name?\n: ' CONNECTION_NAME
read -rep $'SSID?\n: ' SSID
read -rep $'Username?\n: ' USERNAME
read -rep $'Password?\n: ' PASSWORD 

nmcli con add type wifi ifname wlp2s0 con-name $CONNECTION_NAME ssid $SSID
nmcli con edit id $CONNECTION_NAME
set ipv4.method auto
set 802-1x.eap peap
set 802-1x.phase2-auth mschapv2
set 802-1x.identity $USERNAME
set 802-1x.password $PASSWORD
set 802-1x.anonymous-identity anonymous
set wifi-sec.key-mgmt wpa-eap
save
activate
