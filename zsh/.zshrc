#!/bin/zsh
# Best Goddamn zshrc in the whole world.
# Author: Seth House <seth@eseth.com>
# thanks to Adam Spiers, Steve Talley, Aaron Toponce, and Unix Power Tools
# Modified: 2009-10-11
# Modified: 2016-07-20 Changed prompt - Ashish Gupta
# Modified: 2017-09-25 Got rid of unneeded functions and moved all aliases to .aliasrc

local -a precmd_functions

# {{{ setting options

autoload edit-command-line
autoload -U compinit
autoload -U zmv
autoload zcalc

setopt appendhistory

setopt                          \
        auto_cd                 \
        auto_pushd              \
        chase_links             \
        noclobber               \
        complete_aliases        \
        extended_glob           \
        hist_ignore_all_dups    \
        hist_ignore_space       \
        ignore_eof              \
        share_history           \
        noflowcontrol           \
        list_types              \
        mark_dirs               \
        path_dirs               \
        prompt_percent          \
        prompt_subst            \
        rm_star_wait


# Push a command onto a stack allowing you to run another command first
bindkey '^J' push-line

# }}}
# {{{ environment settings

umask 027

path+=( $HOME/bin /sbin /usr/sbin /usr/local/sbin ); path=( ${(u)path} );
CDPATH=$CDPATH::$HOME:/usr/local

HISTFILE=$HOME/.zsh_history
HISTFILESIZE=65536  # search this with `grep | sort -u`
HISTSIZE=4096
SAVEHIST=4096

REPORTTIME=60       # Report time statistics for progs that take more than a minute to run
WATCH=notme         # Report any login/logout of other users
WATCHFMT='%n %a %l from %m at %T.'

# utf-8 in the terminal, will break stuff if your term isn't utf aware
export LANG=en_US.UTF-8
export LC_ALL=$LANG
export LC_COLLATE=C

export VISUAL='gvim -v'
export EDITOR='vim'
export GIT_EDITOR=$EDITOR
export LESS='-imJMWR'
export PAGER="less $LESS"
export MANPAGER=$PAGER
export GIT_PAGER=$PAGER
export BROWSER='google-chrome'

export XDG_CONFIG_HOME="$HOME/.config"

#-------- Color output for some commands
if [ -x /usr/bin/dircolors ]; then
        eval "$(/usr/bin/dircolors)"
fi

#-------- Color Manpages
export LESS_TERMCAP_mb=$'\E[01;31m'             # begin blinking
export LESS_TERMCAP_md=$'\E[01;31m'             # begin bold
export LESS_TERMCAP_me=$'\E[0m'                 # end mode
export LESS_TERMCAP_se=$'\E[0m'                 # end standout-mode                 
export LESS_TERMCAP_so=$'\E[01;44;33m'          # begin standout-mode - info box                              
export LESS_TERMCAP_ue=$'\E[0m'                 # end underline
export LESS_TERMCAP_us=$'\E[01;32m'             # begin underline
#export MANPAGER="/usr/bin/most -s"             # color using most


# }}}
# {{{ completions

compinit -C

zstyle ':completion:*' list-colors "$LS_COLORS"

zstyle -e ':completion:*:(ssh|scp|sshfs|ping|telnet|nc|rsync):*' hosts '
    reply=( ${=${${(M)${(f)"$(<~/.ssh/config)"}:#Host*}#Host }:#*\**} )'

# }}}
# {{{ theme

# Set vi-mode and create a few additional Vim-like mappings
bindkey -v
bindkey "^?" backward-delete-char
bindkey -M vicmd "^R" redo
bindkey -M vicmd "u" undo
bindkey -M vicmd "ga" what-cursor-position
bindkey -M viins '^p' history-beginning-search-backward
bindkey -M vicmd '^p' history-beginning-search-backward
bindkey -M viins '^n' history-beginning-search-forward
bindkey -M vicmd '^n' history-beginning-search-forward

# Allows editing the command line with an external editor
zle -N edit-command-line
bindkey -M vicmd "v" edit-command-line

# }}}
# {{{ aliases

if [[ -r ~/dotfiles/zsh/.aliasrc ]]; then
        . ~/dotfiles/zsh/.aliasrc
fi

# }}}
# ..() Switch to parent directory by matching on partial name {{{1
# Usage:
# cd /usr/share/doc/zsh
# .. s      # cd's to /usr/share

function .. () {
    (( $# == 0 )) && { cd .. && return }

    local match_idx
    local -a parents matching_parents new_path
    parents=( ${(s:/:)PWD} )
    matching_parents=( ${(M)${parents[1,-2]}:#"${1}"*} )

    if (( ${#matching_parents} )); then
        match_idx=${parents[(i)${matching_parents[-1]}]}
        new_path=( ${parents[1,${match_idx}]} )

        cd "/${(j:/:)new_path}"
        return $?
    fi

    return 1
}

# }}}
# {{{ genpass()
# Generates a tough password of a given length

function genpass() {
    if [ ! "$1" ]; then
        echo "Usage: $0 20"
        echo "For a random, 20-character password."
        return 1
    fi
    dd if=/dev/urandom count=1 2>/dev/null | tr -cd 'A-Za-z0-9!@#$%^&*()_+' | cut -c-$1
}

# }}}
# {{{ bookletize()
# Converts a PDF to a fold-able booklet sized PDF
# Print it double-sided and fold in the middle

bookletize ()
{
    (( $+commands[pdfinfo] )) && (( $+commands[pdflatex] )) || {
        error 1 "Missing req'd pdfinfo or pdflatex"
    }

    pagecount=$(pdfinfo $1 | awk '/^Pages/{print $2+3 - ($2+3)%4;}')

    # create single fold booklet form in the working directory
    pdflatex -interaction=batchmode \
    '\documentclass{book}\
    \usepackage{pdfpages}\
    \begin{document}\
    \includepdf[pages=-,signature='$pagecount',landscape]{'$1'}\
    \end{document}' 2>&1 >/dev/null
}

# }}}
# {{{ joinpdf()
# Merges, or joins multiple PDF files into "joined.pdf"

joinpdf () {
    gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=joined.pdf "$@"
}

# }}}
# Output total memory currently in use by you {{{1

memtotaller() {
    /bin/ps -u $(whoami) -o pid,rss,command | awk '{sum+=$2} END {print "Total " sum / 1024 " MB"}'
}


# This function extracts any compressed file using
# the appropriate utility.

function extract() {
	if [ $# != 1 ]; then
	  echo -n "file> "
	  read file
	else
	  file="$1"
	fi

	if [ ! -f $file ]; then
	  echo "No such file: $file"
	  return 1
	fi

	case "$file" in
	  *.tar.7z)  7z e $file;;
	  *.tar.bz2) tar xjf $file;;
	  *.tar.gz)  tar xzf $file;;
	  *.bz2)     bunzip2 $file;;
	  *.gz)      gunzip $file;;
	  *.rar)     rar x $file;;
	  *.tar)     tar xf $file;;
	  *.tbz2)    tar xjf $file;;
	  *.tgz)     tar xzf $file;;
	  *.zip)     unzip $file;;
	  *.Z)       uncompress $file;;
	  *)         echo "$file is of unknown file type";;
	esac

	if [ $? = 0 ]; then
	  echo $file extraction complete
	fi
}

# This is my function to backup folders on my Arch Linux system
# to my Raspberry Pi NAS.
function my_rsync() {
        if [ $# -lt 2 ] || [ $# -gt 3 ]; then
                echo "Usage: my_rsync [--dry-run] <srcdir> <dstdir>"
                return 1
        fi

        if [ $# = 3 ]; then
                OPTS=(--dry-run)
                SRCDIR="$2"
                DSTDIR="$3"
        else
                OPTS=()
                SRCDIR="$1"
                DSTDIR="$2"
        fi

        if [ ! -d "$SRCDIR" ]; then
                echo "$SRCDIR doesn't exist"
                return 2
        fi

        OPTS+=( --update 
                --archive 
                --recursive 
                --delete 
                --times 
                --exclude='$RECYCLE.BIN' 
                --exclude='.Trash-1000' 
                '--exclude=System Volume Information' 
                --chown=root:root 
                --human-readable 
                --verbose 
                --progress 
                --stats)

        rsync $OPTS "$SRCDIR/" "$DSTDIR"

        if [ $? = 0 ]; then
                echo "rsync completed successfully!"
        else
                echo "rsync ERROR!"
        fi
}


# This backs up all folders on my Arch/Windows system to my Raspberry Pi NAS.
function my_backup() {
        if [ $# != 1 ]; then
                echo "Usage: Backup <Raspberry Pi IP Address>"
                return 1
        fi

        IPADDR="$1"
        WINHOME="/mnt/cdrive/Users/ashish"
        ARCHHOME="/home/ashish"
        NASHOME="pi@${IPADDR}:/mnt/Backup/"
        SRCFOLDERS=("$WINHOME/Downloads" "$WINHOME/Documents" "$ARCHHOME/Ebooks" "$ARCHHOME/Music")
        DSTFOLDERS=(Downloads Documents eBooks Music)

        if [ ! -d "$WINHOME" ]; then
            echo "Please mount the Windows partition to /mnt/cdrive."
            return 1
        fi
               
    
        i=0
        while (( i++ < $#SRCFOLDERS )); do 
                my_rsync --dry-run $SRCFOLDERS[i] "${NASHOME}$DSTFOLDERS[i]"
                echo "Sync ${SRCFOLDERS[i]}? (yes/no):"
                read ANSWER
                if [[ $ANSWER = (#i)"yes" ]]; then
                        my_rsync $SRCFOLDERS[i] "${NASHOME}$DSTFOLDERS[i]"
                        echo "Press <ENTER> to continue"
                        read
                fi
        done

        echo "*** DONE BACKUP ***"
        return 0
}
        
# Run precmd functions
precmd_functions=( precmd_prompt grep_options )

# Set up prompt
autoload -Uz promptinit
promptinit
prompt adam1

# EOF
