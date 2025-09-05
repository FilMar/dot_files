#!/usr/bin/env python3

import subprocess
import json
import os
from pathlib import Path

def get_monitors():
    """Get list of connected monitors"""
    try:
        result = subprocess.run(['hyprctl', 'monitors', '-j'], capture_output=True, text=True)
        if result.returncode == 0:
            monitors = json.loads(result.stdout)
            return [monitor['name'] for monitor in monitors]
        return []
    except:
        return ['DP-1', 'HDMI-A-2']  # fallback

def get_wallpapers(directory):
    """Get list of wallpaper files from directory"""
    if not Path(directory).exists():
        return []
    
    extensions = {'.jpg', '.jpeg', '.png', '.webp', '.bmp', '.tiff'}
    wallpapers = []
    
    for file_path in Path(directory).rglob('*'):
        if file_path.suffix.lower() in extensions:
            wallpapers.append(str(file_path))
    
    return sorted(wallpapers)

def get_items():
    """Get list of wallpaper files"""
    # Default wallpaper directories
    wallpaper_dirs = [
        os.path.expanduser("~/Pictures/Wallpapers"),
        os.path.expanduser("~/wallpapers"),
        os.path.expanduser("~/mega/3_resources/images"),
        os.path.expanduser("~/Pictures"),
    ]
    
    all_wallpapers = []
    for directory in wallpaper_dirs:
        wallpapers = get_wallpapers(directory)
        all_wallpapers.extend(wallpapers)
    
    if not all_wallpapers:
        return ["No wallpapers found in common directories"]
    
    # Format for display: show just filename, keep full path after |
    formatted = []
    for wallpaper in all_wallpapers:
        filename = Path(wallpaper).name
        formatted.append(f"{filename}|{wallpaper}")
    
    return formatted

def get_prompt():
    """Get fzf prompt for this mode"""
    return "🖼️ "

def get_preview_command():
    """Get preview command for fzf"""
    script_dir = Path(__file__).parent.parent
    preview_script = script_dir / "preview_wallpaper.py"
    return f"python3 {preview_script} {{}}"

def set_wallpaper(wallpaper_path, monitor=None, transition="fade"):
    """Set wallpaper using swww"""
    cmd = ['swww', 'img', wallpaper_path]
    
    if monitor:
        cmd.extend(['-o', monitor])
    
    cmd.extend(['--transition-type', transition, '--transition-duration', '2'])
    
    try:
        subprocess.run(cmd, check=True)
        return True
    except subprocess.CalledProcessError:
        return False

def handle_selection(selected_item):
    """Handle the selected item"""
    if '|' in selected_item:
        wallpaper_path = selected_item.split('|')[1]
        
        # Get monitors and ask user to choose
        monitors = get_monitors()
        if len(monitors) > 1:
            monitor_options = ["All monitors"] + monitors
            monitor_input = '\n'.join(monitor_options)
            
            try:
                monitor_result = subprocess.run(
                    ['fzf', '--prompt=📺 Monitor: ', '--layout=reverse'],
                    input=monitor_input,
                    text=True,
                    capture_output=True
                )
                
                if monitor_result.returncode == 0:
                    selected_monitor = monitor_result.stdout.strip()
                    if selected_monitor == "All monitors":
                        selected_monitor = None
                    
                    return set_wallpaper(wallpaper_path, selected_monitor)
            except Exception:
                pass
        else:
            # Single monitor or fallback
            return set_wallpaper(wallpaper_path)
    
    return False
