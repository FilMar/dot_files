#!/bin/zsh
# Shared environment variables for zsh

# Dotfiles configuration path with portable fallback
# Derived paths
export VIM_FILES="$CONFIG_HOME/vim_files"
export ZSH_FILES="$CONFIG_HOME/zsh_files"
export ZSH="$HOME/.oh-my-zsh"

# Notes path with portable fallback
if [[ -e $HOME/MEGA/2_areas/notes/ ]]; then
    export NOTES_HOME="$HOME/MEGA/2_areas/notes"
else
    export NOTES_HOME="$HOME/mega/2_areas/notes"
fi

# Shell configuration
export TERM="xterm-256color"
export SHELL="/usr/bin/zsh"
export EDITOR="/usr/bin/nvim"


# Path modifications (portable)
export PATH="$PATH:$HOME/.modular/bin":$HOME/.elan/env:$HOME/.opencode/bin:$HOME/.local/bin:$HOME/.local/share/bob/nvim-bin:$HOME/.npm-global/bin/

# Shell identification for starship
export STARSHIP_SHELL="zsh"

# Add more variables here as needed
# export PROJECT_HOME="$HOME/projects"
# export WORKSPACE="$CONFIG_HOME/workspace"

# Taskwarrior: auto-detect repo-local .taskrc on cd.
# Use chpwd_functions so TASKRC is re-evaluated on every directory change
# (env.sh is sourced once at shell start, not on cd).
autoload -U add-zsh-hook
__taskrc_chpwd() {
  if [[ -f .taskrc ]]; then
    export TASKRC="$PWD/.taskrc"
  else
    unset TASKRC
  fi
}
add-zsh-hook chpwd __taskrc_chpwd
# Initial check for the current directory at shell start
__taskrc_chpwd

# Source profile if exists
if [[ -e ~/.profile ]]; then
    source ~/.profile
fi

# mise
if command -v mise &>/dev/null; then
    eval "$(mise activate zsh)"
elif [[ -x "$HOME/.local/bin/mise" ]]; then
    eval "$($HOME/.local/bin/mise activate zsh)"
fi

