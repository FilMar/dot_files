#!/usr/bin/env python3

import sys
import os
import subprocess
import importlib.util
from pathlib import Path

def load_mode(mode_name):
    """Dynamically load a launcher mode"""
    script_dir = Path(__file__).parent
    mode_file = script_dir / "launchers" / f"{mode_name}.py"
    
    if not mode_file.exists():
        return None
    
    spec = importlib.util.spec_from_file_location(mode_name, mode_file)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    
    return module

def run_fzf(items, prompt="❯ ", preview_command=None):
    """Run fzf with given items and prompt, optionally with preview"""
    if not items:
        print("No items found")
        return None
    
    fzf_input = '\n'.join(items)
    fzf_args = ['fzf', '--prompt=' + prompt, '--layout=reverse', '--border']
    
    if preview_command:
        fzf_args.extend(['--preview', preview_command])
        fzf_args.extend(['--preview-window', 'hidden'])  # Initially hidden, will be controlled by preview script
    
    try:
        result = subprocess.run(
            fzf_args,
            input=fzf_input,
            text=True,
            capture_output=True
        )
        
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
            
    except Exception as e:
        print(f"Error running fzf: {e}")
    
    return None

def list_available_modes():
    """List available launcher modes"""
    script_dir = Path(__file__).parent
    launchers_dir = script_dir / "launchers"
    
    if not launchers_dir.exists():
        return []
    
    modes = []
    for file in launchers_dir.glob("*.py"):
        if file.name != "__init__.py":
            modes.append(file.stem)
    
    return sorted(modes)

def main():
    if len(sys.argv) < 2:
        mode_name = "apps"  # default
    elif sys.argv[1] in ["-h", "--help"]:
        available_modes = list_available_modes()
        print("Usage: launcher.py [mode]")
        print("Available modes:", ", ".join(available_modes))
        return
    else:
        mode_name = sys.argv[1]
    
    # Load the mode
    mode = load_mode(mode_name)
    if not mode:
        available_modes = list_available_modes()
        print(f"Mode '{mode_name}' not found")
        print("Available modes:", ", ".join(available_modes))
        return 1
    
    # Check required functions
    required_functions = ['get_items', 'get_prompt', 'handle_selection']
    for func_name in required_functions:
        if not hasattr(mode, func_name):
            print(f"Mode '{mode_name}' missing required function: {func_name}")
            return 1
    
    # Get items and run fzf
    items = mode.get_items()
    if not items:
        print(f"No items found for mode '{mode_name}'")
        return 1
    
    # Check if mode supports preview
    preview_command = None
    if hasattr(mode, 'get_preview_command'):
        preview_command = mode.get_preview_command()
    
    selected = run_fzf(items, mode.get_prompt(), preview_command)
    if selected:
        success = mode.handle_selection(selected)
        return 0 if success else 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())