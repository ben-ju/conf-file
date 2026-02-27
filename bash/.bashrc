# =========================================================================== #
#  1. INIT & HISTORY
# =========================================================================== #
[ -z "$PS1" ] && return

export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTTIMEFORMAT="%F %T  "
shopt -s histappend checkwinsize cdspell autocd

# =========================================================================== #
#  ENVIRONMENT & PATH
# =========================================================================== #
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER='nvim +Man!'

export GOPATH="$HOME/go"
export PATH="$HOME/.fzf/bin:$PATH"          # newer fzf must come before /usr/bin/fzf
export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH="$PATH:$HOME/.local/opt/go/bin:$GOPATH/bin"
export PATH="$PATH:$HOME/.cargo/bin:$HOME/.local/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# =========================================================================== #
#  COLORS & PROMPT
# =========================================================================== #
# Enable terminal color support
export TERM=xterm-256color

# Prompt color codes (only used inside PS1 — must stay \[ \] wrapped)
_R='\[\e[0m\]'   # reset
_BD='\[\e[1m\]'  # bold
_CY='\[\e[96m\]' # bright cyan   — username
_BL='\[\e[94m\]' # bright blue   — host
_YL='\[\e[33m\]' # yellow        — path
_MG='\[\e[35m\]' # magenta       — git branch
_GN='\[\e[92m\]' # bright green  — ok arrow
_RD='\[\e[91m\]' # bright red    — error arrow

# Git branch shown in prompt
_git_ps1() {
  local b
  b=$(git symbolic-ref --short HEAD 2>/dev/null) ||
    b=$(git rev-parse --short HEAD 2>/dev/null) ||
    return
  printf ' (%s)' "$b"
}

# PROMPT_COMMAND rebuilds PS1 every command so exit-code coloring works
_build_ps1() {
  local rc=$?
  local arrow_col
  [ $rc -eq 0 ] && arrow_col=$_GN || arrow_col=$_RD
  PS1="${_BD}${_CY}\u${_R}@${_BD}${_BL}\h${_R} ${_YL}\w${_R}${_MG}\$(_git_ps1)${_R}\n${arrow_col}❯${_R} "
}
PROMPT_COMMAND='_build_ps1'

# Colored ls
if command -v dircolors &>/dev/null; then
  eval "$(dircolors -b)"
fi
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# =========================================================================== #
#  6. ALIASES
# =========================================================================== #
alias ll='ls -alFh'
alias la='ls -A'
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'
alias v='nvim'
alias c='clear'
# Extract any archive format
extract() {
  [ ! -f "$1" ] && {
    echo "not a file: $1"
    return 1
  }
  case "$1" in
  *.tar.bz2 | *.tbz2) tar xjf "$1" ;;
  *.tar.gz | *.tgz) tar xzf "$1" ;;
  *.tar.xz) tar xJf "$1" ;;
  *.tar.zst) tar --zstd -xf "$1" ;;
  *.tar) tar xf "$1" ;;
  *.bz2) bunzip2 "$1" ;;
  *.gz) gunzip "$1" ;;
  *.zip) unzip "$1" ;;
  *.7z) 7z x "$1" ;;
  *.rar) unrar x "$1" ;;
  *.xz) unxz "$1" ;;
  *.zst) zstd -d "$1" ;;
  *) echo "unknown format: $1" ;;
  esac
}

# =========================================================================== #
#  COMPLETION & FZF
# =========================================================================== #
if ! shopt -oq posix; then
  [ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
fi

export FZF_DEFAULT_OPTS="
  --height 40% --layout=reverse --border rounded
  --color=fg:#cdd6f4,bg:#1e1e2e,hl:#89b4fa
  --color=fg+:#cdd6f4,bg+:#313244,hl+:#89dceb
  --color=info:#cba6f7,prompt:#89b4fa,pointer:#f38ba8
  --color=marker:#a6e3a1,spinner:#f5c2e7,header:#6c7086
  --prompt='❯ ' --pointer='▶' --marker='✔'
"
export FZF_DEFAULT_COMMAND='find . -type f -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./target/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

[ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# =========================================================================== #
#  MISC
# =========================================================================== #

mdread() { glow -p "${1:--}"; }

[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000
