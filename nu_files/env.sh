#!/bin/bash
# Shared environment variables for all shells
# This file defines variables in POSIX format that can be sourced by any shell

# Dotfiles configuration path with portable fallback
if [[ -e $HOME/MEGA/dot_files/ ]]; then
    export CONFIG_HOME="$HOME/MEGA/dot_files"
else
    export CONFIG_HOME="$HOME/git_projects/dot_files"
fi

# Derived paths
export VIM_FILES="$CONFIG_HOME/vim_files"
export ZSH_FILES="$CONFIG_HOME/zsh_files"

# Notes path with portable fallback
if [[ -e $HOME/MEGA/2_areas/notes/ ]]; then
    export NOTES_HOME="$HOME/MEGA/2_areas/notes"
else
    export NOTES_HOME="$HOME/mega/2_areas/notes"
fi

# Shell configuration
export ZSH="$HOME/.oh-my-zsh"
export TERM="xterm-256color"
export SHELL="/usr/bin/zsh"

# Path modifications (portable)
export PATH="$PATH:$HOME/.modular/bin"

# Shell identification for starship
export STARSHIP_SHELL="zsh"

# Add more variables here as needed
# export PROJECT_HOME="$HOME/projects"
# export WORKSPACE="$CONFIG_HOME/workspace"