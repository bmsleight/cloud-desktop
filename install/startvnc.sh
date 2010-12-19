#!/bin/bash
/root/start_connect_switch.sh &
su cloud -c "Xvfb :1 -cc 4 -screen 0 1024x768x16 &"
sleep 5
# -listen ipaddr 
x11vnc -display :1 -ssl SAVE -httpdir /usr/share/x11vnc/classes/ssl/ -httpsredir  -forever -unixpw cloud >/tmp/xll.txt 2>&1 &
su cloud -c "export DISPLAY=:1 ; startxfce4"


