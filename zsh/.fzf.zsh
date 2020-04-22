#!/bin/zsh

#export FZF_CTRL_T_OPTS="--select-1 --exit-0"

# c - browse chrome history
c() {
  local cols sep google_history open
  cols=$(( COLUMNS / 3 ))
  sep='{::}'

  if [ "$(uname)" = "Darwin" ]; then
    google_history="$HOME/Library/Application Support/Google/Chrome/Default/History"
    open=open
  else
    google_history="$HOME/.config/google-chrome/Default/History"
    open=xdg-open
  fi
  cp -f "$google_history" /tmp/h
  sqlite3 -separator $sep /tmp/h \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs -n 1 $open > /dev/null 2> /dev/null
}

# b - browse chrome bookmarks
b() {
  local open ruby output
  open=xdg-open
  ruby=$(which ruby)
  output=$($ruby << EORUBY
# encoding: utf-8

require 'json'
FILE = '~/.config/google-chrome/Default/Bookmarks'
CJK  = /\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/

def build parent, json
  name = [parent, json['name']].compact.join('/')  
  if json['type'] == 'folder'
    json['children'].map { |child| build name, child }
  else
    { name: name, url: json['url'] }
  end
end

def just str, width
  str.ljust(width - str.scan(CJK).length)
end

def trim str, width
  len = 0
  str.each_char.each_with_index do |char, idx|
    len += char =~ CJK ? 2 : 1
    return str[0, idx] if len > width
  end
  str
end

width = `tput cols`.to_i / 2
json  = JSON.load File.read File.expand_path FILE
items = json['roots']
        .values_at(*%w(bookmark_bar synced other))
        .compact
        .map { |e| build nil, e }
        .flatten

items.each do |item|
  name = trim item[:name], width
  puts [just(name, width),
        item[:url]].join("\t\x1b[36m") + "\x1b[m"
end
EORUBY
)
  #fzf-tmux -u 30% --ansi --multi --no-hscroll --tiebreak=begin |

  echo -e "$output"                                            |
          fzf --ansi --multi --tiebreak=begin |
          #for url in  $(awk 'BEGIN { FS = "\t" } { print $2 }'); do xdg-open $url; done
          awk 'BEGIN { FS = "\t" } { print $2 }' |
                 xargs -n 1 xdg-open
  
  #xargs xdg-open &>/dev/null

}

# fkill - kill process
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

man-find() {
    f=$(fd . $MANPATH/man${1:-1} -t f -x echo {/.} | fzf) && man $f
}
fman() {
    man -k . | fzf --prompt='Man> ' | awk '{print $1}' | xargs -r man
}

# fh - repeat history
#fh() {
#  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -r 's/ *[0-9]*\*? *//' | sed -r 's/\\/\\\\/g')
#}

# fh - repeat history
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -r 's/ *[0-9]*\*? *//' | sed -r 's/\\/\\\\/g')
}

# fp - file preview
fp() {
  #find . -type f | fzf --preview 'bat --wrap auto --terminal-width 40 --style=numbers --color=always {} | head -500'
  find . -type f 2> /dev/null | fzf --select-1 --exit-0 --preview 'bat --style=numbers --color=always {} | head -500' | sed -e "s/'/'\\\\''/g;s/\(.*\)/'\1'/" | ([ -z - ] || xdg-open ) 2> /dev/null
}

# pac-preview - preview installed pkgs
pac-preview() {
  pacman -Slq | fzf -m --preview 'pacman -Si {1}' | xargs -ro sudo pacman -S
}

zle -N c
bindkey '^x^h' c
zle -N b
bindkey '^b'  b
zle -N pac-preview
bindkey '^x^a'  pac-preview
zle -N fkill
bindkey '^k' fkill
zle -N fh
bindkey '^h' fh
zle -N fman
bindkey '^x^m' fman
zle -N fp
bindkey '^x^p' fp

#export FZF_COMPLETION_TRIGGER=''
#bindkey '^T' fzf-completion
#bindkey '^I' $fzf_default_completion

# Using highlight (http://www.andre-simon.de/doku/highlight/en/highlight.html)
#export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
#export FZF_CTRL_T_OPTS="--select-1 --exit-0"

#export FZF_CTRL_R_OPTS='--sort --exact'
