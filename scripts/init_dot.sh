
#!/bin/bash
# Initialize all dotfiles symlinks

DOT_FILES="$HOME/git_projects/dot_files"

if [ -e "$DOT_FILES" ]; then
    echo "dot_files found"

    echo "ghostty"
    ln -sf "$DOT_FILES/ghostty_files" "$HOME/.config/ghostty"
    
    echo "zsh"
    ln -sf "$DOT_FILES/zsh_files/zsh_config" "$HOME/.zshrc"

    echo "starship"
    ln -sf "$DOT_FILES/zsh_files/starship.toml" "$HOME/.config/starship.toml"
    
    echo "neovim"
    ln -sf "$DOT_FILES/vim_files" "$HOME/.config/nvim"
    
    echo "niri"
    ln -sf "$DOT_FILES/niri_files" "$HOME/.config/niri"
    
    echo "noctalia"
    ln -sf "$DOT_FILES/noctalia_files" "$HOME/.config/noctalia"
    
    echo "Setup complete!"
else
    echo "Error: dot_files directory not found"
    exit 1
fi
