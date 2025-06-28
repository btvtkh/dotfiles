#!/bin/sh

xrdb -merge ~/.Xresources
export GTK_THEME='Colloid-Astel-Blue'
# xrandr --output DisplayPort-0 --mode 1920x1080 --rate 165.00 &
# /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
picom &
exec awesome