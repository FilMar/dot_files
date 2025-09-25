#!/usr/bin/env python3

import subprocess
import json

def get_items():
    """Get clipboard history from cliphist"""
    try:
        result = subprocess.run(
            ['cliphist', 'list'],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            return ["No clipboard history found"]
            
        items = []
        for line in result.stdout.strip().split('\n'):
            if line.strip():
                # cliphist format: ID\tCONTENT
                # Show first 100 chars with indicator if longer
                content = line.split('\t', 1)[1] if '\t' in line else line
                # Replace newlines with spaces for display
                content = content.replace('\n', ' ').replace('\r', ' ')
                display = content[:100] + "..." if len(content) > 100 else content
                items.append(line)  # Keep full line for selection
                
        return items if items else ["No clipboard history found"]
        
    except Exception as e:
        print(f"Error getting clipboard history: {e}")
        return ["No clipboard history found"]


def get_prompt():
    """Get fzf prompt for this mode"""
    return "📋 "


def get_preview_command():
    """Get preview command for fzf to show full content"""
    # Extract content part after tab and show full text
    return "echo {} | cut -f2-"


def handle_selection(selected_item):
    """Handle the selected clipboard item"""
    if selected_item == "No clipboard history found":
        return False
        
    try:
        # Get the ID (first part before tab)
        clip_id = selected_item.split('\t')[0]
        
        # Use cliphist to decode and copy the selected item
        result = subprocess.run(
            ['cliphist', 'decode', clip_id],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            # Copy to clipboard using wl-copy
            subprocess.run(
                ['wl-copy'],
                input=result.stdout,
                text=True,
                check=True
            )
            return True
        else:
            print(f"Error decoding clipboard item: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"Error copying to clipboard: {e}")
        return False