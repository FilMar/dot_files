#!/usr/bin/env python3

import sys
import subprocess
import time
import os
from pathlib import Path

def cleanup_existing_preview():
    """Kill any existing imv preview windows"""
    try:
        # Find imv processes with 'preview' in title
        result = subprocess.run(['pgrep', '-f', 'imv.*preview'], capture_output=True, text=True)
        if result.stdout.strip():
            pids = result.stdout.strip().split('\n')
            for pid in pids:
                subprocess.run(['kill', pid], capture_output=True)
    except:
        pass

def show_floating_preview(image_path):
    """Show image in floating imv window"""
    try:
        # Launch imv with floating window
        subprocess.Popen([
            'imv', 
            '-x', 'preview',  # Set window title
            '-s', 'shrink',   # Scale mode
            '-p',             # Stay on top
            image_path
        ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
        # Small delay to let imv start
        time.sleep(0.1)
        
        # Make it floating and position it
        subprocess.run([
            'hyprctl', 'dispatch', 'togglefloating'
        ], capture_output=True)
        
        # Resize and position (small preview window)
        subprocess.run([
            'hyprctl', 'dispatch', 'resizeactive', '300', '200'
        ], capture_output=True)
        
        subprocess.run([
            'hyprctl', 'dispatch', 'moveactive', '20', '20'
        ], capture_output=True)
        
    except Exception as e:
        print(f"Error showing preview: {e}", file=sys.stderr)

def main():
    if len(sys.argv) != 2:
        sys.exit(1)
    
    selected_line = sys.argv[1]
    
    # Extract image path from formatted line
    if '|' in selected_line:
        image_path = selected_line.split('|')[1]
    else:
        image_path = selected_line
    
    # Check if file exists
    if not Path(image_path).exists():
        sys.exit(1)
    
    # Clean up any existing previews
    cleanup_existing_preview()
    
    # Add small delay before showing preview
    time.sleep(0.3)
    
    # Show the preview
    show_floating_preview(image_path)

if __name__ == "__main__":
    main()