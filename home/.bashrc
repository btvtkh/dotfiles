#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='\[\e[96m\]\u\[\e[39m\]@\[\e[96m\]\H\[\e[39m\]: \[\e[95m\]\w\[\e[39m\] $ '

[ -z "$DISPLAY" -a x$XDG_VTNR = x1 ] && exec startx

alias ls='ls --color=auto'