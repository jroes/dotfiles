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

# A better find
alias fd=fdfind

# Rust
export CARGO_HOME=${HOME}/.local/rust/cargo
export RUSTUP_HOME=${HOME}/.local/rust/rustup
export PATH=${CARGO_HOME}/bin:${PATH}

# Zig
export PATH=${HOME}/.local/zig-linux-aarch64-0.13.0:${PATH}

# Pure, a prettier prompt
fpath+=(${HOME}/.local/share/zsh/pure)
autoload -U promptinit; promptinit
prompt pure

# Load private env vars
source ~/.private_env_vars

# Fzf config
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
FZF_CONFIG=${HOME}/.config/fzf/0.44.1
[ -f ${FZF_CONFIG}/completion.zsh ] && source ${FZF_CONFIG}/completion.zsh
[ -f ${FZF_CONFIG}/key-bindings.zsh ] && source ${FZF_CONFIG}/key-bindings.zsh
ls -lah ${FZF_CONFIG}

. "$HOME/.local/bin/env"
export TERM=xterm-256color

. "$HOME/.asdf/asdf.sh"

# bun completions
[ -s "/home/jroes/.bun/_bun" ] && source "/home/jroes/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"
