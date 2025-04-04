# zmodload zsh/zprof
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

autoload -Uz compinit
compinit -u

eval "$(starship init zsh)"

os_name=$(uname -s)

# Python venv
alias venv-activate="source .venv/bin/activate"
alias venv-create="python3 -m venv .venv ; venv-activate"
alias venv-delete="rm -rfv .venv"

# A prettier ls
alias ls=lsd

# Vim keybindings
bindkey -v

# Nvim configuration
export PATH=${PATH}:/opt/nvim/bin
export EDITOR=nvim

if [ "$os_name" = "Linux" ]; then
    # A better find
    alias fd=fdfind
fi

# Rust
export CARGO_HOME=${HOME}/.local/rust/cargo
export RUSTUP_HOME=${HOME}/.local/rust/rustup
export PATH=${CARGO_HOME}/bin:${PATH}

# Zig
export PATH=${HOME}/.local/zig-linux-aarch64-0.13.0:${PATH}

source ~/.private_env_vars

# Fzf config
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
source <(fzf --zsh)

# Git checkout with fzf
fzf-git-checkout() {
    git rev-parse HEAD > /dev/null 2>&1 || return

    local branch=$(git branch --all | grep -v HEAD |
        sed "s/.* //" | sed "s#remotes/[^/]*/##" |
        sort -u | fzf)

    if [[ $branch != "" ]]; then
        git checkout $branch
    fi
}

# Create the alias
alias gco='fzf-git-checkout'

if [ "$os_name" = "Linux" ]; then
    . "$HOME/.local/bin/env"

elif [ "$os_name" = "Darwin" ]; then
    if [ ! -f ~/.work_settings.sh ]; then
        . /opt/homebrew/opt/asdf/libexec/asdf.sh
        export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
    fi
else
    echo "Unsupported OS: $os_name"
fi

if [ -f ~/.work_settings.sh ]; then
    source ~/.work_settings.sh
fi

export TERM=xterm-256color

# bun completions
#[ -s "/home/jroes/.bun/_bun" ] && source "/home/jroes/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"

export FLYCTL_INSTALL="/home/jroes/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# fnm
# FNM_PATH="/Users/jroes/Library/Application Support/fnm"
# if [ -d "$FNM_PATH" ]; then
#   export PATH="/Users/jroes/Library/Application Support/fnm:$PATH"
#   eval "`fnm env`"
# fi

#compdef gt
###-begin-gt-completions-###
#
# yargs command completion script
#
# Installation: gt completion >> ~/.zshrc
#    or gt completion >> ~/.zprofile on OSX.
#
_gt_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" gt --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _gt_yargs_completions gt
###-end-gt-completions-###

# zprof
