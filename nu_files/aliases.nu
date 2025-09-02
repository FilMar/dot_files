# Nushell Aliases - Converted from zsh

# Basic system aliases (simple ones work as aliases)
alias vim = nvim
alias vid = nvim .
alias py = python3
alias cat = bat
# Use Nushell's built-in ls (much better than exa - creates tables!)
alias la = ls -la
alias gith = git log --graph --oneline
alias ngit = nvim -c Neogit

# Complex aliases converted to functions
def cp [...args] { ^cp -i ...$args }
def df [...args] { ^df -h ...$args }
def free [...args] { ^free -m ...$args }
def batInfo [] { sudo tlp-stat -b }
def tree [...args] { ^tree -C ...$args }

# Git function (was alias but needs multiple commands)
def gitu [] {
    git add .
    git commit
    git push
}

# SSH connection
def ssmax [] { 
    ssh -i ~/.ssh/LightsailDefaultKey-eu-west-3.pem ubuntu@35.181.223.102 
}

# Utility functions  
def sheet [] {
    let list = (curl -s cht.sh/:list)
    let selection = ($list | lines | input list "Select topic:")
    if ($selection | is-not-empty) {
        curl $"cht.sh/($selection)"
    }
}

def hist [] {
    history | where command =~ (input "Search: ") | get command
}
