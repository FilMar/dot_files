# Nushell Environment Configuration

# Import POSIX environment variables from shared env.sh file
let env_script = ($nu.config-path | path dirname | path join "env.sh")

# Source the POSIX env file and import variables (excluding system ones)
if ($env_script | path exists) {
    let env_vars = (bash -c $"source ($env_script) && env" | lines | where ($it | str contains "=") | parse "{name}={value}")
    for var in $env_vars {
        # Try to set each variable, skip if it fails (Nu-managed vars)
        try {
            load-env {($var.name): ($var.value)}
        } catch {
            # Silently skip variables that Nu doesn't allow (like PWD, etc.)
        }
    }
}

# Override shell identification for starship  
$env.STARSHIP_SHELL = "nu"

# Default environment variables
$env.PROMPT_MULTILINE_INDICATOR = "::: "

# Starship prompt (modern alternative to typewritten theme)
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# History configuration
$env.config = ($env.config | upsert history {
    max_size: 5000
    sync_on_enter: true
    file_format: "plaintext"
})

# Load completions for external commands
$env.config = ($env.config | upsert completions {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "fuzzy"
})

# Key bindings similar to vi mode
$env.config = ($env.config | upsert keybindings [
    {
        name: completion_menu
        modifier: none
        keycode: tab
        mode: [emacs vi_normal vi_insert]
        event: {
            until: [
                { send: menu name: completion_menu }
                { send: menunext }
            ]
        }
    }
    {
        name: history_menu
        modifier: control
        keycode: char_r
        mode: [emacs vi_insert vi_normal]
        event: { send: menu name: history_menu }
    }
])

# External completions can be configured here if needed
# $env.config = ($env.config | upsert external_completer null)
