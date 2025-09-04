# Nushell Functions - Converted from zsh

# Warp function - navigate with fzf
def --env warp [] {
    cd $env.HOME
    
    let new_dir = (^fd -t d --exclude 'node_modules' --exclude '__pycache__' --exclude 'target' --exclude 'dist' --exclude 'build' | ^fzf --preview 'exa -la --color=always {}')
    
    if ($new_dir | is-not-empty) {
        cd $new_dir
        
        # Check for virtual environment
        if (".venv" | path exists) {
            print "Virtual environment found"
        }
    }
}

# Git workflow functions
def ginit [] {
    git init
    touch .gitignore README.md
    (pwd) | save README.md
    git add --all
    git commit -m "I'm Batman"
    git checkout -b develop
}

def gif [name: string] {
    let branch_name = $"feature/($name)"
    git checkout -b $branch_name
    git push --set-upstream origin $branch_name
}

def gir [name: string] {
    let branch_name = $"refactor/($name)"
    git checkout -b $branch_name
    git push --set-upstream origin $branch_name
}

def gib [name: string] {
    let branch_name = $"bugfix/($name)"
    git checkout -b $branch_name
    git push --set-upstream origin $branch_name
}

def grelease [version: string] {
    let branch_name = $"release/($version)"
    git checkout -b $branch_name
    git push --set-upstream origin $branch_name
    
    if ("./scripts/docker_build.py" | path exists) {
        python3 ./scripts/docker_build.py --latest
    }
}

def getignore [lang: string] {
    let url = $"https://raw.githubusercontent.com/github/gitignore/main/($lang).gitignore"
    http get $url
}
