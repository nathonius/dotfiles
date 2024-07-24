HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='code'
fi

# Lazy load NVM to speed up init
export NVM_COMPLETION=true

alias bco="better-commits"
alias zshrc="code ~/.zshrc"
alias dotfiles="code ~/.dotfiles"
if command -v espanso &> /dev/null; then
  ESPANSO_PATH=$(espanso path config)
  alias espanso-edit="code \$ESPANSO_PATH/."
fi

export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$HOME/.deno/bin:$PATH"

# Homebrew
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  [ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh
fi

if [[ ! -f "$HOME/.antigen.zsh" ]]; then
  curl -L git.io/antigen > ~/.antigen.zsh
fi
source "$HOME/.antigen.zsh"

# Antigen
# Uncomment to log antigen output
# export ANTIGEN_LOG=$HOME/antigen.log
antigen use oh-my-zsh

antigen bundle git
antigen bundle olets/zsh-abbr@main
antigen bundle wfxr/forgit
antigen bundle lukechilds/zsh-better-npm-completion
antigen bundle sudo
antigen bundle dirhistory
antigen bundle lukechilds/zsh-nvm
antigen bundle marlonrichert/zsh-hist@main

antigen apply

# Configure some zsh plugins
if command -v zstyle &> /dev/null; then
  zstyle ':hist:*' auto-format no
fi

# Oh My Posh
if command -v oh-my-posh &> /dev/null; then
  eval "$(oh-my-posh init zsh --config ~/.oh-my-posh.json)"
fi

# fzf
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'

  gch() {
    GCH_BRANCH="$(git branch --all | fzf | tr -d '[:space:]')"
    git checkout "$GCH_BRANCH"
    print -S "git checkout $GCH_BRANCH"
  }
fi

# zoxide
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
if command -v pyenv &> /dev/null; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# ng completions
if command -v ng version &> /dev/null; then 
  source <(ng completion script)
fi

# alias apt to nala, if it's installed
if command -v nala &> /dev/null; then
  apt() { 
    command nala "$@"
  }
  sudo() {
    if [ "$1" = "apt" ]; then
      shift
      command sudo nala "$@"
    else
      command sudo "$@"
    fi
  }
fi