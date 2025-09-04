#!/usr/bin/env nu

# Initialize all dotfiles symlinks
def main [] {
    let dot_files_path = ($env.HOME | path join "git_projects/dot_files")
    
    if ($dot_files_path | path exists) {
        print "dot_files found"
        
        print "bashrc (env.sh)"
        ^ln -sf ($dot_files_path | path join "nu_files/env.sh") ($env.HOME | path join ".bashrc")
        
        print "nushell"
        ^ln -sf ($dot_files_path | path join "nu_files") ($env.HOME | path join ".config/nushell")
        
        print "neovim"
        ^ln -sf ($dot_files_path | path join "vim_files") ($env.HOME | path join ".config/nvim")
        
        print "hyprland" 
        ^ln -sf ($dot_files_path | path join "hypr_files") ($env.HOME | path join ".config/hypr")
        
        print "alacritty"
        ^ln -sf ($dot_files_path | path join "alacritty_files") ($env.HOME | path join ".config/alacritty")
        
        print "waybar"
        ^ln -sf ($dot_files_path | path join "bar_files") ($env.HOME | path join ".config/waybar")
        
        print "wired"
        ^ln -sf ($dot_files_path | path join "wired_files") ($env.HOME | path join ".config/wired")
        
        print "starship"
        ^ln -sf ($dot_files_path | path join "nu_files/starship.toml") ($env.HOME | path join ".config/starship.toml")
        
        print "Setup complete!"
    } else {
        print "Error: dot_files directory not found"
        exit 1
    }
}