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

def interactive_wallpaper_selector():
    """Interactive wallpaper selector with fzf"""
    # Default wallpaper directories
    wallpaper_dirs = [
        str(Path.home() / "Pictures" / "wallpapers"),
        str(Path.home() / "MEGA" / "3_resources" / "images"),
        str(Path.home() / "Pictures"),
        "/usr/share/pixmaps",
        "/usr/share/backgrounds"
    ]
    
    # Find wallpapers
    all_wallpapers = []
    for directory in wallpaper_dirs:
        if Path(directory).exists():
            all_wallpapers.extend(get_wallpapers(directory))
    
    if not all_wallpapers:
        print("No wallpapers found in:")
        for d in wallpaper_dirs:
            print(f"  - {d}")
        return
    
    # Prepare fzf input with preview
    fzf_input = '\n'.join(all_wallpapers)
    
    try:
        # Run fzf with image preview if available
        fzf_cmd = [
            'fzf',
            '--prompt=🖼️ Wallpaper: ',
            '--height=80%',
            '--layout=reverse',
            '--border',
            '--preview-window=right:40%',
        ]
        
        # Try to add image preview if chafa is available
        try:
            subprocess.run(['which', 'chafa'], check=True, capture_output=True)
            fzf_cmd.append('--preview=chafa --size=40x20 --format=symbols {}')
        except subprocess.CalledProcessError:
            fzf_cmd.append('--preview=echo "File: {}\nSize: $(du -h {} | cut -f1)\nPath: {}"')
        
        result = subprocess.run(
            fzf_cmd,
            input=fzf_input,
            text=True,
            capture_output=True
        )
        
        if result.returncode == 0 and result.stdout.strip():
            selected_wallpaper = result.stdout.strip()
            
            # Get monitors for multi-monitor choice
            monitors = get_monitors()
            
            if len(monitors) > 1:
                # Ask which monitor(s)
                monitor_options = ["All monitors"] + monitors
                monitor_input = '\n'.join(monitor_options)
                
                monitor_result = subprocess.run(
                    ['fzf', '--prompt=📺 Monitor: ', '--height=40%', '--layout=reverse'],
                    input=monitor_input,
                    text=True,
                    capture_output=True
                )
                
                if monitor_result.returncode == 0 and monitor_result.stdout.strip():
                    monitor_choice = monitor_result.stdout.strip()
                    
                    if monitor_choice == "All monitors":
                        success = set_wallpaper(selected_wallpaper)
                    else:
                        success = set_wallpaper(selected_wallpaper, monitor_choice)
                    
                    if success:
                        print(f"✅ Wallpaper set: {Path(selected_wallpaper).name}")
                    else:
                        print(f"❌ Failed to set wallpaper")
                else:
                    print("Cancelled")
            else:
                # Single monitor
                success = set_wallpaper(selected_wallpaper)
                if success:
                    print(f"✅ Wallpaper set: {Path(selected_wallpaper).name}")
                else:
                    print(f"❌ Failed to set wallpaper")
        else:
            print("Cancelled")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    interactive_wallpaper_selector()
