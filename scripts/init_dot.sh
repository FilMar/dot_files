

if [ -e $HOME/git_projects/dot_files ]; then
    echo "dot_files found"
    echo "zsh"
    ln -sf $HOME/git_projects/dot_files/zsh_files/zshConfig $HOME/.zshrc
    echo "neovim"
    ln -sfn $HOME/git_projects/dot_files/vim_files $HOME/.config/nvim
    echo "hyprland"
    ln -sfn $HOME/git_projects/dot_files/hypr_files $HOME/.config/hypr
    echo "wezterm"
    ln -sfn $HOME/git_projects/dot_files/wezterm_files $HOME/.config/wezterm
    echo "waybar"
    ln -sfn $HOME/git_projects/dot_files/waybar_files $HOME/.config/waybar
    echo "wofi"
    ln -sfn $HOME/git_projects/dot_files/wofi_files $HOME/.config/wofi
fi
