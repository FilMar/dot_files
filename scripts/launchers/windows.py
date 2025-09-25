#!/usr/bin/env python3

import subprocess
import json


def get_items():
    """Get list of windows from hyprctl"""
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


def get_prompt():
    """Get fzf prompt for this mode"""
    return "🪟 "


def handle_selection(selected_item):
    """Handle the selected item"""
    if '|' in selected_item:
        address = selected_item.split('|')[1]
        try:
            # Focus the window first
            subprocess.run(
                ['hyprctl', 'dispatch', 'focuswindow', f'address:{address}'])
            # Then swap it to master position
            subprocess.run(
                ['hyprctl', 'dispatch', 'layoutmsg', 'swapwithmaster'])
            return True
        except Exception as e:
            print(f"Error focusing/mastering window: {e}")
            return False
    return False
