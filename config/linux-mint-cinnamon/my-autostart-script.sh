#!/usr/bin/zsh

nemo &
gnome-terminal &
sleep 10

wmctrl -r home -t 1
wmctrl -r home -b add,maximized_vert
wmctrl -r home -b add,maximized_horz

wmctrl -r terminal -t 2
wmctrl -r terminal -b add,maximized_vert
wmctrl -r terminal -b add,maximized_horz

wmctrl -a terminal
