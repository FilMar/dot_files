#!/usr/bin/env python3

import subprocess
import json

def get_app_count_and_list():
    try:
        # Get windows from hyprctl
        result = subprocess.run(
            ['hyprctl', 'clients', '-j'],
            capture_output=True, text=True
        )
        
        if result.returncode != 0:
            return {"text": "apps: 0", "tooltip": "No apps running"}
            
        windows = json.loads(result.stdout)
        
        if not windows:
            return {"text": "apps: 0", "tooltip": "No apps running"}
        
        # Create app list for tooltip
        app_list = []
        for window in windows:
            title = window.get('title', 'Untitled')
            class_name = window.get('class', 'Unknown')
            
            if len(title) > 40:
                title = title[:37] + "..."
            
            if title == 'Untitled' or not title:
                display = class_name
            else:
                display = f"{title} ({class_name})"
            
            app_list.append(display)
        
        # Sort and create tooltip
        app_list.sort()
        tooltip = "\n".join(app_list)
        
        return {
            "text": f"apps: {len(windows)}",
            "tooltip": tooltip
        }
        
    except Exception as e:
        return {"text": " !", "tooltip": f"Error: {str(e)}"}

if __name__ == "__main__":
    print(json.dumps(get_app_count_and_list()))