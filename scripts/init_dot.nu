#!/usr/bin/env nu

# Initialize dotfiles symlinks
def main [] {
    let dot_files_path = ($env.HOME | path join "git_projects/dot_files")
    
    if ($dot_files_path | path exists) {
        print "dot_files found"
        
        print "nushell"
        ln -sf ($dot_files_path | path join "nu_files") ($env.HOME | path join ".config/nushell")
        
        print "neovim"
        ln -sfn ($dot_files_path | path join "vim_files") ($env.HOME | path join ".config/nvim")
        
        print "hyprland" 
        ln -sfn ($dot_files_path | path join "hypr_files") ($env.HOME | path join ".config/hypr")
        
        print "ghostty"
        ln -sfn ($dot_files_path | path join "ghostty_files") ($env.HOME | path join ".config/ghostty")
        
        print "waybar"
        ln -sfn ($dot_files_path | path join "bar_files") ($env.HOME | path join ".config/waybar")
        
        print "wofi"
        ln -sfn ($dot_files_path | path join "wofi_files") ($env.HOME | path join ".config/wofi")
        
        print "qtile"
        ln -sfn ($dot_files_path | path join "qtile_files") ($env.HOME | path join ".config/qtile")
        
        print "Setup complete!"
    } else {
        print "Error: dot_files directory not found"
        exit 1
    }
}