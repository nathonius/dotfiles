HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="loopy"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git forgit dirhistory zsh-hist)

source $ZSH/oh-my-zsh.sh

# User configuration

command_exists() {
  command -v "$@" >/dev/null 2>&1
}


# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='code'
fi

export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$HOME/.deno/bin:$PATH"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.

alias c="clear"
alias bco="better-commits"
alias zshrc="code ~/.zshrc"
alias dotfiles="code ~/.dotfiles"
if command -v espanso &> /dev/null; then
  ESPANSO_PATH=$(espanso path config)
  alias espanso-edit="code \$ESPANSO_PATH/."
fi

# Homebrew
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  [ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh
fi

# Configure some zsh plugins
if command_exists zstyle; then
  zstyle ':hist:*' auto-format no
fi

# fzf
if command_exists fzf; then
  source <(fzf --zsh)
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'

  gch() {
    GCH_BRANCH="$(git branch --all --format='%(HEAD) %(refname:short) - %(objectname:short) - %(contents:subject) - %(authorname) (%(committerdate:relative))' | fzf | awk -F ' ' '{print $1}')"
    if [ -n "$GCH_BRANCH" ]; then
      git checkout "$GCH_BRANCH"
      print -S "git checkout $GCH_BRANCH"
    fi
  }
fi

# zoxide
if command_exists zoxide; then
  eval "$(zoxide init zsh)"
  alias j="z"
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
if command_exists pyenv; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# ng completions
if command_exists ng version; then 
  source <(ng completion script)
fi

# alias apt to nala, if it's installed
if command_exists nala; then
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

# alias cat to bat, if it's installed
if command_exists bat; then
  export BAT_THEME="Catppuccin Frappe"
  export BAT_STYLE="numbers,changes,grid"
  cat() {
    command bat -P "$@"
  }
fi

# on some platforms it's batcat instead of bat
if command_exists batcat; then
  export BAT_THEME="Catppuccin Frappe"
  export BAT_STYLE="numbers,changes,grid"
  cat() {
    command batcat -P "$@"
  }
fi

# alias batman to man
if command_exists batman; then
  man() {
    command batman "$@"
  }
fi

# batpipe less
if command_exists batpipe; then
    eval "$(batpipe)"
fi

# delta
if command_exists delta; then
    git config --global core.pager delta
    git config --global interactive.diffFilter 'delta --color-only'
    git config --global delta.navigate true
    git config --global merge.conflictStyle zdiff3
fi