#!/usr/bin/env python3

import subprocess
import json

def get_window_list():
    try:
        # Get all windows
        result = subprocess.run(
            ['hyprctl', 'clients', '-j'],
            capture_output=True, text=True
        )
        
        if result.returncode != 0:
            return {"text": "No windows", "class": "empty"}
            
        windows = json.loads(result.stdout)
        
        if not windows:
            return {"text": "Desktop", "class": "empty"}
        
        # Get active window address
        active_result = subprocess.run(
            ['hyprctl', 'activewindow', '-j'],
            capture_output=True, text=True
        )
        
        active_address = ""
        if active_result.returncode == 0:
            active_window = json.loads(active_result.stdout)
            active_address = active_window.get('address', '')
        
        # Process windows
        window_items = []
        active_window_item = None
        
        for window in windows:
            title = window.get('title', 'Untitled')
            class_name = window.get('class', 'Unknown')
            address = window.get('address', '')
            
            # Truncate long titles
            if len(title) > 20:
                title = title[:17] + "..."
            
            if not title or title == 'Untitled':
                display_title = class_name
            else:
                display_title = title
            
            window_item = {
                'title': display_title,
                'address': address,
                'is_active': address == active_address
            }
            
            if window_item['is_active']:
                active_window_item = window_item
            else:
                window_items.append(window_item)
        
        # Catppuccin colors for windows
        colors = ["blue", "green", "yellow", "peach", "mauve", "pink", "teal", "sky"]
        
        # Build display with colors: active first, then others
        display_parts = []
        color_index = 0
        
        if active_window_item:
            color = colors[color_index % len(colors)]
            display_parts.append(f'<span color="#{get_color_hex(color)}">● {active_window_item["title"]}</span>')
            color_index += 1
        
        for window in window_items:
            color = colors[color_index % len(colors)]
            display_parts.append(f'<span color="#{get_color_hex(color)}">○ {window["title"]}</span>')
            color_index += 1
        
        display_text = " | ".join(display_parts)
        
        return {
            "text": display_text,
            "class": "window-list"
        }
        
    except Exception as e:
        return {"text": f"Error: {str(e)}", "class": "error"}

def get_color_hex(color_name):
    colors = {
        "blue": "89b4fa",
        "green": "a6e3a1", 
        "yellow": "f9e2af",
        "peach": "fab387",
        "mauve": "cba6f7",
        "pink": "f5c2e7",
        "teal": "94e2d5",
        "sky": "89dceb"
    }
    return colors.get(color_name, "cdd6f4")

if __name__ == "__main__":
    print(json.dumps(get_window_list()))