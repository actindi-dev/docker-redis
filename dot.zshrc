stty stop undef

#umask 077

alias ls='ls -F --color=auto'
alias l=ls
alias gd='dirs -v; echo -n "select number: "; read newdir; cd -"$newdir"'
alias -g L='| lv -c'
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g S='| sed'
alias sayounara='sudo halt'

bindkey "\C-p" up-line-or-search
bindkey "\C-n" down-line-or-search

export PS1="${HOST}:%~%# "

#setopt autocd autopushd pushdignoredups
#setopt correct correctall
#setopt extendedglob
#setopt noclobber
#setopt completeinword

zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
autoload -U compinit
compinit

HISTFILE=$HOME/.zsh-history
HISTSIZE=100000
SAVEHIST=100000
setopt extended_history
function history-all { history -E 1 }
setopt share_history
setopt histignorealldups
