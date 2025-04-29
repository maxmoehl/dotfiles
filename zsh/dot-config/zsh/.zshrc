#!/usr/bin/env zsh

if [[ -f ~/.profile ]]; then
  source ~/.profile
else
  echo "WARNING: No ~/.profile found"
fi

autoload -Uz compinit edit-command-line

compinit

compdef sship=ssh

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes

bindkey -e

zle -N edit-command-line
bindkey '^V' edit-command-line

# man 1 zshoptions
setopt \
  AUTO_CD \
  CD_SILENT \
  EXTENDED_HISTORY \
  HIST_IGNORE_DUPS \
  HIST_IGNORE_SPACE \
  HIST_NO_STORE \
  PROMPT_SUBST \
  SHARE_HISTORY \

# man 1 zshparam
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=2000
SAVEHIST=2000

# Completions
export FPATH="${HOME}/.config/zsh/completions/:${FPATH}"

# Tools
command -v fzf    &> /dev/null && source <(fzf --zsh)
command -v atuin  &> /dev/null && eval "$(atuin init zsh --disable-up-arrow)"
command -v direnv &> /dev/null && eval "$(direnv hook zsh)"

# Other config
for f in ~/.config/zsh/config.d/*; do
  . "${f}";
done
