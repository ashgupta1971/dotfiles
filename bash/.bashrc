#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

#-------- Color Manpages
#export LESS_TERMCAP_mb=$'\E[01;31m'             # begin blinking
#export LESS_TERMCAP_md=$'\E[01;31m'             # begin bold
#export LESS_TERMCAP_me=$'\E[0m'                 # end mode
#export LESS_TERMCAP_se=$'\E[0m'                 # end standout-mode                 
#export LESS_TERMCAP_so=$'\E[01;44;33m'          # begin standout-mode - info box                              
#export LESS_TERMCAP_ue=$'\E[0m'                 # end underline
#export LESS_TERMCAP_us=$'\E[01;32m'             # begin underline
export MANPAGER="/usr/bin/most -s"             # color using most
