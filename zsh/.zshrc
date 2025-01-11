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
path+=( $HOME/Scripts $HOME/python_work/My_OptionsPlay )
CDPATH=$CDPATH::$HOME:/usr/local


#-------- Color output for some commands
if [ -x /usr/bin/dircolors ]; then
        eval "$(/usr/bin/dircolors)"
fi

HISTFILE=$HOME/.zsh_history
if [[ -r ~/dotfiles/zsh/.envvars ]]; then
        . ~/dotfiles/zsh/.envvars
fi

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

# Calculate the annualized return of a short call/put option trade.
function areturn() {
    premium=$1
    stockprice=$2
    expiry=$3
    rawreturn=`echo "scale=4; $premium / $stockprice * 100" | bc --mathlib`

    DTE=`echo "scale=0; ($(date -d ""$expiry"" +%s) - $(date -d ""00:00"" +%s )) / (24*3600)" | bc --mathlib`
    echo "DTE = $DTE days"
    printf "Raw return = %.2f %%\n" $rawreturn
    printf "Annualized return = %.2f %%\n" $(echo "(e(l(1 +  $premium / $stockprice)*(365 / $DTE)) - 1) * 100" | bc --mathlib)
}

# The following command scans an image from the HP Officejet. It must be run on the RPI2.
# It must be run as root or using sudo.
function scan-rpi2() {
    scanimage --format=jpeg --mode Gray -p -v -d 'hpaio:/usb/Officejet_4630_series?serial=CN47B392YQ05Y0' > out1.jpg
}

# This trick lists all git repos by a user (function arg) - got it from commanline.fu
function list-git-repos() {
    curl -s "https://api.github.com/users/$1/repos?per_page=1000" | python <(echo "import json,sys;v=json.load(sys.stdin);for i in v:; print(i['git_url']);" | tr ';' '\n')
}

# A Rudimentary backup function to copy files to an external USB HDD
# DEPRECATED!!!!!
#function backup() {
#    OLDCWD=$(pwd)
#    cd ~ashish
#
#    BACKUP_LOG="backup-$(date +"%H:%M:%S").log"
#    touch $BACKUP_LOG
#
#    for d in Documents Downloads EBooks Music VBox-shared python_work sql_work Shared; do
#        cp --archive --update --verbose $d /run/media/ashish/FujitsuHDD/Backup | grep -v "^skipped" | tee -a $BACKUP_LOG
#    done
#    cp --archive --update --verbose "Google Drive" /run/media/ashish/FujitsuHDD/Backup | grep -v "^skipped" | tee -a $BACKUP_LOG
#
#    cd "$OLDCWD"
#}
#
# Use autojump package to quickly change dirs
function j() {
    cd "$(autojump "$1")"
}

# Run precmd functions
precmd_functions=( precmd_prompt grep_options )

# Set up prompt
autoload -Uz promptinit
promptinit
#prompt adam1
prompt adam2
#prompt powerlevel9k

preexec() {
    cmd_start="$SECONDS"
}

precmd() {
  local cmd_end="$SECONDS"
  elapsed=$((cmd_end-cmd_start))
#  echo $elapsed
  #PS1="$elapsed "
  #PS1="$(date -d@$elapsed -u +%H:%M:%S)"
}

[ -f ~/dotfiles/zsh/.rsync.zsh ] && source ~/dotfiles/zsh/.rsync.zsh
[ -f ~/dotfiles/zsh/.fzf.zsh ] && source ~/dotfiles/zsh/.fzf.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# EOF

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval $(thefuck --alias)
# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
    \builtin pwd -L
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
    # shellcheck disable=SC2164
    \builtin cd -- "$@"
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
function __zoxide_hook() {
    # shellcheck disable=SC2312
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize hook.
# shellcheck disable=SC2154
if [[ ${precmd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] && [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]]; then
    chpwd_functions+=(__zoxide_hook)
fi

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function __zoxide_z() {
    # shellcheck disable=SC2199
    if [[ "$#" -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ "$#" -eq 1 ]] && { [[ -d "$1" ]] || [[ "$1" = '-' ]] || [[ "$1" =~ ^[-+][0-9]$ ]]; }; then
        __zoxide_cd "$1"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" && __zoxide_cd "${result}"
    fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
    \builtin local result
    result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

function z() {
    __zoxide_z "$@"
}

function zi() {
    __zoxide_zi "$@"
}

# Completions.
if [[ -o zle ]]; then
    __zoxide_result=''

    function __zoxide_z_complete() {
        # Only show completions when the cursor is at the end of the line.
        # shellcheck disable=SC2154
        [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0

        if [[ "${#words[@]}" -eq 2 ]]; then
            # Show completions for local directories.
            _files -/
        elif [[ "${words[-1]}" == '' ]]; then
            # Show completions for Space-Tab.
            # shellcheck disable=SC2086
            __zoxide_result="$(\command zoxide query --exclude "$(__zoxide_pwd || \builtin true)" --interactive -- ${words[2,-1]})" || __zoxide_result=''

            # Bind '\e[0n' to helper function.
            \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
            # Send '\e[0n' to console input.
            \builtin printf '\e[5n'
        fi

        # Report that the completion was successful, so that we don't fall back
        # to another completion function.
        return 0
    }

    function __zoxide_z_complete_helper() {
        if [[ -n "${__zoxide_result}" ]]; then
            # shellcheck disable=SC2034,SC2296
            BUFFER="z ${(q-)__zoxide_result}"
            \builtin zle reset-prompt
            \builtin zle accept-line
        else
            \builtin zle reset-prompt
        fi
    }
    \builtin zle -N __zoxide_z_complete_helper

    [[ "${+functions[compdef]}" -ne 0 ]] && \compdef __zoxide_z_complete z
fi

# =============================================================================
#
# To initialize zoxide, add this to your configuration (usually ~/.zshrc):
#
eval "$(zoxide init zsh)"
