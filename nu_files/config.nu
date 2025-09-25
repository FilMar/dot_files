# Nushell Configuration - Converted from zsh

# Set up colors for terminal
$env.TERM = "xterm-256color"

# Shell settings equivalent to zsh vi mode
$env.config = {
    edit_mode: emacs
    show_banner: false
    use_ansi_coloring: true
    color_config: {
        separator: white
        leading_trailing_space_bg: { attr: n }
        header: green_bold
        empty: blue
        bool: light_cyan
        int: white
        duration: white
        date: purple
        range: white
        float: white
        string: white
        nothing: white
        binary: white
        cell-path: white
        row_index: green_bold
        record: white
        list: white
        block: white
        hints: dark_gray
    }
    history: {
        max_size: 5000
        sync_on_enter: true
        file_format: "plaintext"
    }
}

# Environment variables setup
def setup_env [] {
    # Dotfiles paths
    let config_home = if ($env.HOME | path join "MEGA/dot_files" | path exists) {
        $env.HOME | path join "MEGA/dot_files"
    } else {
        $env.HOME | path join "git_projects/dot_files"
    }
    
    $env.CONFIG_HOME = $config_home
    $env.VIM_FILES = ($config_home | path join "vim_files")
    $env.NU_FILES = ($config_home | path join "nu_files")
    
    # Notes path
    let notes_home = if ($env.HOME | path join "MEGA/2_areas/notes" | path exists) {
        $env.HOME | path join "MEGA/2_areas/notes"
    } else {
        $env.HOME | path join "mega/2_areas/notes"
    }
    
    $env.NOTES_HOME = $notes_home
    
    # Add modular to PATH if it exists
    let modular_path = ($env.HOME | path join ".modular/bin")
    if ($modular_path | path exists) {
        $env.PATH = ($env.PATH | append $modular_path)
    }
}


## ~/.config/nushell/env.nu
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu

#~/.config/nushell/config.nu
source ~/.cache/carapace/init.nu

# Run environment setup
setup_env

# Source additional config files
source aliases.nu
source functions.nu
