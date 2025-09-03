#!/usr/bin/env python3

import subprocess
import json

def get_window_info():
    try:
        # Get active window
        active_result = subprocess.run(
            ['hyprctl', 'activewindow', '-j'],
            capture_output=True, text=True
        )
        
        if active_result.returncode != 0:
            return {"text": "", "class": "empty"}
            
        active_window = json.loads(active_result.stdout)
        
        # Get all windows to check for grouping
        all_result = subprocess.run(
            ['hyprctl', 'clients', '-j'],
            capture_output=True, text=True
        )
        
        if all_result.returncode != 0:
            return format_single_window(active_window)
            
        all_windows = json.loads(all_result.stdout)
        
        # Check if active window is grouped
        active_grouped = active_window.get('grouped', [])
        
        if active_grouped:
            # Find all windows in the same group
            group_windows = []
            active_address = active_window.get('address', '')
            
            for window in all_windows:
                window_grouped = window.get('grouped', [])
                if window_grouped and set(window_grouped) & set(active_grouped):
                    title = window.get('title', 'Untitled')
                    if len(title) > 20:
                        title = title[:17] + "..."
                    
                    is_active = window.get('address', '') == active_address
                    group_windows.append({
                        'title': title,
                        'active': is_active
                    })
            
            # Format grouped display
            if len(group_windows) > 1:
                # Active window first, others after
                active_title = next(w['title'] for w in group_windows if w['active'])
                other_titles = [w['title'] for w in group_windows if not w['active']]
                
                display = f"● {active_title}"
                if other_titles:
                    display += f" | {' | '.join(other_titles)}"
                
                return {
                    "text": f" {display}",
                    "class": "grouped", 
                    "tooltip": f"Grouped: {len(group_windows)} windows"
                }
        
        # Single window (not grouped)
        return format_single_window(active_window)
        
    except Exception as e:
        return {"text": "Error", "class": "error"}

def format_single_window(window):
    title = window.get('title', 'Desktop')
    class_name = window.get('class', '')
    
    if len(title) > 30:
        title = title[:27] + "..."
    
    if title == "":
        title = class_name or "Desktop"
    
    return {
        "text": title,
        "class": "single",
        "tooltip": f"{class_name}: {window.get('title', '')}"
    }

if __name__ == "__main__":
    print(json.dumps(get_window_info()))