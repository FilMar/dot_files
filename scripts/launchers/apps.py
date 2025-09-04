#!/usr/bin/env python3

import os
import subprocess
import re
from pathlib import Path

def get_items():
    """Get list of desktop applications"""
    apps = []
    desktop_dirs = [
        Path("/usr/share/applications"),
        Path.home() / ".local/share/applications"
    ]
    
    for desktop_dir in desktop_dirs:
        if not desktop_dir.exists():
            continue
            
        for desktop_file in desktop_dir.glob("*.desktop"):
            try:
                with open(desktop_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Skip if NoDisplay=true
                if "NoDisplay=true" in content:
                    continue
                    
                # Extract Name and Exec
                name_match = re.search(r'^Name=(.+)$', content, re.MULTILINE)
                exec_match = re.search(r'^Exec=(.+)$', content, re.MULTILINE)
                
                if name_match and exec_match:
                    name = name_match.group(1)
                    exec_cmd = exec_match.group(1)
                    # Remove %U %u %F %f flags
                    exec_cmd = re.sub(r' %[UuFf]', '', exec_cmd)
                    apps.append(f"{name}|{exec_cmd}")
                    
            except Exception:
                continue
    
    return apps

def get_prompt():
    """Get fzf prompt for this mode"""
    return "❯ "

def handle_selection(selected_item):
    """Handle the selected item"""
    if '|' in selected_item:
        cmd = selected_item.split('|')[1]
        # Launch app in background
        subprocess.Popen(cmd.split(), start_new_session=True, 
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    return False