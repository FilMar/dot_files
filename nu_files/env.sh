#!/bin/bash
# Minimal .bashrc with environment variables
# This file serves as both env config and .bashrc

# Dotfiles configuration path with portable fallback
if [[ -e $HOME/MEGA/dot_files/ ]]; then
    export CONFIG_HOME="$HOME/MEGA/dot_files"
else
    export CONFIG_HOME="$HOME/git_projects/dot_files"
fi

# Derived paths
export VIM_FILES="$CONFIG_HOME/vim_files"

# Notes path with portable fallback
if [[ -e $HOME/MEGA/2_areas/notes/ ]]; then
    export NOTES_HOME="$HOME/MEGA/2_areas/notes"
else
    export NOTES_HOME="$HOME/mega/2_areas/notes"
fi

# Shell configuration
export TERM="xterm-256color"
export SHELL="/usr/bin/bash"

# Path modifications (portable)
export PATH="$PATH:$HOME/.modular/bin"

# Shell identification for starship
export STARSHIP_SHELL="bash"

# Add more variables here as needed
# export PROJECT_HOME="$HOME/projects"
# export WORKSPACE="$CONFIG_HOME/workspace"

# Source profile if exists
if [[ -e ~/.profile ]]; then
    source ~/.profile
fi

# Launch Nushell for interactive sessions while keeping bash as login shell
if [[ $- == *i* ]] && [[ -z "$NU_STARTED" ]] && [[ -n "$PS1" ]]; then
    export NU_STARTED=1
    exec nu
fi