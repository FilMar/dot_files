#!/usr/bin/env nu

# Download gitignore templates from GitHub
def main [template: string] {
    let url = $"https://raw.githubusercontent.com/github/gitignore/main/($template).gitignore"
    http get $url
}