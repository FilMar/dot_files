# Nushell Environment Configuration

# Default environment variables
$env.PROMPT_MULTILINE_INDICATOR = "::: "

# Starship prompt (modern alternative to typewritten theme)
$env.STARSHIP_SHELL = "nu"

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