
#!/bin/bash
# Initialize all dotfiles symlinks

DOT_FILES="$HOME/git_projects/dot_files"

if [ -e "$DOT_FILES" ]; then
    echo "dot_files found"
    
    echo "bashrc (env.sh)"
    ln -sf "$DOT_FILES/nu_files/env.sh" "$HOME/.bashrc"
    
    echo "nushell"
    ln -sf "$DOT_FILES/nu_files" "$HOME/.config/nushell"
    
    echo "neovim"
    ln -sf "$DOT_FILES/vim_files" "$HOME/.config/nvim"
    
    echo "hyprland"
    ln -sf "$DOT_FILES/hypr_files" "$HOME/.config/hypr"
    
    echo "alacritty"
    ln -sf "$DOT_FILES/alacritty_files" "$HOME/.config/alacritty"
    
    echo "waybar"
    ln -sf "$DOT_FILES/bar_files" "$HOME/.config/waybar"
    
    echo "wired"
    ln -sf "$DOT_FILES/wired_files" "$HOME/.config/wired"
    
    echo "starship"
    ln -sf "$DOT_FILES/nu_files/starship.toml" "$HOME/.config/starship.toml"
    
    echo "Setup complete!"
else
    echo "Error: dot_files directory not found"
    exit 1
fi
