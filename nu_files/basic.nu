# ~/.config/nushell/config.nu

# — Environment Variables & Initialization —
# Powerlevel10k instant prompt not supported; skip.
$env.ZSH = "($env.HOME)/.oh-my-zsh"
$env.TERM = "xterm-256color"
# Default shell set to Nushell; to make it your login shell: run `chsh -s (which nu)`
$env.SHELL = (which nu)

# Source POSIX profile if present
const temp_path = $env.HOME + "/.profile"
if ($temp_path | path exists) { source $temp_path }

# — Dotfiles & Notes Paths —
if ( ($env.HOME + "/MEGA/dot_files/") | path exists) {
  $env.CONFIG_HOME = "($env.HOME)/MEGA/dot_files/"
} else {
  $env.CONFIG_HOME = "($env.HOME)/git_projects/dot_files"
}
$env.VIM_FILES = "($env.CONFIG_HOME)/vim_files"
$env.ZSH_FILES = "($env.CONFIG_HOME)/zsh_files"

if (path exists ($env.HOME + "/MEGA/2_areas/notes/")) {
  $env.NOTES_HOME = "($env.HOME)/MEGA/2_areas/notes/"
} else {
  $env.NOTES_HOME = "($env.HOME)/mega/2_areas/notes/"
}

# — Extend PATH —
$env.PATH = "($env.PATH):/home/fildev/.modular/bin"

# — Prompt —
def prompt [] {
  let user = (whoami)
  let host = (hostname)
  let cwd = $env.PWD | path tail
  $"[$user@$host $cwd] » "
}

# — Aliases —
alias cp [] { cp -i }
alias df [] { df -h }
alias free [] { free -m }
alias vim [] { nvim }
alias vid [] { nvim . }
alias batInfo [] { sudo tlp-stat -b }
alias tree [] { tree -C }
alias py [] { python3 }
alias cat [] { bat }
alias ls [] { exa -l }
alias la [] { exa -lah }
alias sheet [] { curl ($"cht.sh/" + (curl cht.sh/:list | fzf)) }
alias hist [] { history | fzf }
alias gst [] { git status }
alias ngit [] { nvim -c Neogit }
alias ssmax [] { ssh -i ~/.ssh/LightsailDefaultKey-eu-west-3.pem ubuntu@35.181.223.102 }
alias gitu [] { git add . && git commit && git push }
alias gith [] { git log --graph --oneline }

# — Functions —
def _pandoc [options] {
  if (which docker) {
    docker container run --rm -v (pwd):/data --user (id -u):$(id -g) pandoc/extra $options
  } else {
    echo "install docker for use containerized pandoc"
  }
}

def warp [] {
  let current = (pwd)
  cd $env.HOME
  let new_dir = (fd -t d 2>/dev/null | fzf)
  if ($new_dir == '') { cd $current } else { cd $new_dir }
  if (path exists '.venv') { source .venv/bin/activate } else { deactivate }
}

def _fgf [] {
  let repos = (fd -t d -H -g '.git' -E '.*/*' '.git' $env.NOTES_HOME $env.CONFIG_HOME 2>/dev/null | str trim-end '.git')
  for repo in $repos {
    cd $repo; git pull; cd --
  }
}

def note [] {
  let file = (fd . -t f -d 1 $env.NOTES_HOME 2>/dev/null | fzf --print-query | last)
  if ($file == '') { echo "devi scrivere qualcosa" } else { nvim $file }
}

def ginit [] {
  git init
  touch .gitignore README.md
  echo (pwd) > README.md
  git add --all
  git commit -m "I'm Batman"
  git checkout -b develop
}

def gif [name] {
  let branch = $"feature/{$name}"
  git checkout -b $branch
  git push --set-upstream origin $branch
}

def gir [name] {
  let branch = $"refactor/{$name}"
  git checkout -b $branch
  git push --set-upstream origin $branch
}

def gib [name] {
  let branch = $"bugfix/{$name}"
  git checkout -b $branch
  git push --set-upstream origin $branch
}

def grelease [name] {
  let branch = $"release/{$name}"
  git checkout -b $branch
  git push --set-upstream origin $branch
  if (path exists './scripts/docker_build.py') { py ./scripts/docker_build.py --latest }
}

def getignore [template] {
  $"https://raw.githubusercontent.com/github/gitignore/main/{$template}.gitignore" | fetch | str trim
}

# — History —
# Nushell uses its own history mechanism; Zsh-specific HIST* options are not applicable.
