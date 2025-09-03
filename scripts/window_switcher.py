#!/usr/bin/env python3

import subprocess
import json

def get_windows():
    try:
        # Get windows from hyprctl
        result = subprocess.run(
            ['hyprctl', 'clients', '-j'],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            return []
            
        windows = json.loads(result.stdout)
        window_list = []
        
        for window in windows:
            title = window.get('title', 'Untitled')
            class_name = window.get('class', 'Unknown')
            address = window.get('address', '')
            workspace = window.get('workspace', {}).get('name', '?')
            
            # Skip empty titles
            if not title.strip():
                title = class_name
                
            # Format: "Title - Class (workspace)"
            display = f"{title} - {class_name} (ws:{workspace})|{address}"
            window_list.append(display)
            
        return window_list
        
    except Exception as e:
        print(f"Error getting windows: {e}")
        return []

def focus_window(address):
    try:
        subprocess.run(['hyprctl', 'dispatch', 'focuswindow', f'address:{address}'])
    except Exception as e:
        print(f"Error focusing window: {e}")

def main():
    windows = get_windows()
    
    if not windows:
        print("No windows found")
        return
        
    # Run fzf
    fzf_input = '\n'.join(windows)
    try:
        result = subprocess.run(
            ['fzf', '--prompt=🪟 ', '--height=40%', '--layout=reverse', '--border'],
            input=fzf_input,
            text=True,
            capture_output=True
        )
        
        if result.returncode == 0 and result.stdout.strip():
            selected = result.stdout.strip()
            address = selected.split('|')[1]
            focus_window(address)
                           
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()