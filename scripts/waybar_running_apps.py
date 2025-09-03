#!/usr/bin/env python3

import subprocess
import json

def get_running_apps():
    try:
        # Get windows from hyprctl
        result = subprocess.run(
            ['hyprctl', 'clients', '-j'],
            capture_output=True, text=True
        )
        
        if result.returncode != 0:
            return {"text": "No apps", "tooltip": "No running applications"}
            
        windows = json.loads(result.stdout)
        
        # Apps mapping
        app_icons = {
            'firefox': '🦊',
            'telegram': '💬', 
            'discord': '🎮',
            'code': '💻',
            'emacs': '📝',
            'ghostty': '⬛',
            'nautilus': '📁',
            'obs': '🎥',
            'spotify': '🎵',
            'gimp': '🎨'
        }
        
        # Count apps
        app_counts = {}
        app_list = []
        
        for window in windows:
            class_name = window.get('class', '').lower()
            title = window.get('title', 'Untitled')
            
            # Find matching app
            app_name = None
            icon = '⬜'
            
            for app, app_icon in app_icons.items():
                if app in class_name:
                    app_name = app
                    icon = app_icon
                    break
            
            if not app_name:
                app_name = class_name or 'unknown'
                icon = '⬜'
            
            # Count instances
            if app_name not in app_counts:
                app_counts[app_name] = {'count': 0, 'icon': icon, 'titles': []}
            
            app_counts[app_name]['count'] += 1
            if title and title != 'Untitled':
                app_counts[app_name]['titles'].append(title)
        
        # Format display
        if not app_counts:
            return {"text": "No apps", "tooltip": "No running applications"}
        
        # Show icons with counts
        display_parts = []
        tooltip_parts = []
        
        for app_name, info in app_counts.items():
            icon = info['icon']
            count = info['count']
            
            if count > 1:
                display_parts.append(f"{icon}{count}")
            else:
                display_parts.append(icon)
            
            # Tooltip info
            titles = info['titles'][:3]  # Max 3 titles per app
            if titles:
                title_text = ", ".join(titles)
                if len(titles) < count:
                    title_text += f" (+{count - len(titles)} more)"
            else:
                title_text = f"{count} window{'s' if count > 1 else ''}"
            
            tooltip_parts.append(f"{app_name}: {title_text}")
        
        display_text = " ".join(display_parts)
        tooltip_text = "\n".join(tooltip_parts)
        
        return {
            "text": display_text,
            "tooltip": tooltip_text,
            "class": "apps"
        }
        
    except Exception as e:
        return {"text": "Error", "tooltip": f"Error: {str(e)}"}

if __name__ == "__main__":
    print(json.dumps(get_running_apps()))