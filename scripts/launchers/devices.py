#!/usr/bin/env python3

import subprocess
import json


def get_items():
    """Get list of block devices"""
    try:
        # Use lsblk to get block devices with JSON output
        result = subprocess.run(
            ['lsblk', '-J', '-o', 'NAME,SIZE,TYPE,LABEL,MOUNTPOINT,FSTYPE'],
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            return []

        data = json.loads(result.stdout)
        devices = []

        def process_device(device, parent_name=""):
            """Recursively process devices and their children"""
            name = device.get('name', '')
            size = device.get('size', '')
            dev_type = device.get('type', '')
            label = device.get('label', '')
            mountpoint = device.get('mountpoint', '')
            fstype = device.get('fstype', '')

            # Skip loop devices and devices without filesystem
            if dev_type in ['loop', 'rom'] or not fstype:
                # But still process children
                for child in device.get('children', []):
                    process_device(child, name)
                return

            # Create display name
            display_name = label if label else name

            # Show mount status
            status = f"mounted: {mountpoint}" if mountpoint else "not mounted"

            # Format: "Label - Size (Type) [Status]|/dev/name"
            display = f"{display_name} - {size} ({dev_type}) [{status}]|/dev/{name}"
            devices.append(display)

            # Process children (partitions)
            for child in device.get('children', []):
                process_device(child, name)

        # Process all block devices
        for device in data.get('blockdevices', []):
            process_device(device)

        return devices

    except Exception as e:
        print(f"Error getting devices: {e}")
        return []


def get_mountpoint(device_path):
    """Get the mountpoint of a device"""
    try:
        result = subprocess.run(
            ['lsblk', '-n', '-o', 'MOUNTPOINT', device_path],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            mountpoint = result.stdout.strip()
            return mountpoint if mountpoint else None
        return None
    except Exception:
        return None


def get_prompt():
    """Get fzf prompt for this mode"""
    return "💾 "


def unmount_device(device_path):
    """Unmount and safely eject a device"""
    print(f"Unmounting {device_path}...")
    try:
        # First unmount
        result = subprocess.run(
            ['udisksctl', 'unmount', '-b', device_path],
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            print(f"Error unmounting: {result.stderr}")
            return False

        # Then power-off (safe eject for USB devices)
        print(f"Ejecting {device_path}...")
        result = subprocess.run(
            ['udisksctl', 'power-off', '-b', device_path],
            capture_output=True,
            text=True
        )
        if result.returncode != 0:
            # Power-off might fail for internal disks, that's ok
            print(f"Device unmounted (eject not supported)")
        else:
            print(f"Device safely ejected")

        return True
    except Exception as e:
        print(f"Error unmounting device: {e}")
        return False


def open_in_nvim(mountpoint):
    """Open nvim with oil at the given mountpoint"""
    try:
        subprocess.Popen(
            [
                'alacritty',
                '--title=device-browser',
                '-e', 'nvim',
                '-c', 'Oil',
                mountpoint
            ],
            start_new_session=True
        )
        return True
    except Exception as e:
        print(f"Error opening nvim: {e}")
        return False


def handle_selection(selected_item):
    """Handle the selected device"""
    # Extract device path from format: "Label - Size (Type) [Status]|/dev/name"
    if '|' not in selected_item:
        return False

    device_path = selected_item.split('|')[1]

    # Check if already mounted
    mountpoint = get_mountpoint(device_path)

    # If not mounted, mount it
    if not mountpoint:
        print(f"Mounting {device_path}...")
        try:
            result = subprocess.run(
                ['udisksctl', 'mount', '-b', device_path],
                capture_output=True,
                text=True
            )
            if result.returncode != 0:
                print(f"Error mounting: {result.stderr}")
                return False

            # Get the new mountpoint
            mountpoint = get_mountpoint(device_path)
            if not mountpoint:
                print("Device mounted but mountpoint not found")
                return False

        except Exception as e:
            print(f"Error mounting device: {e}")
            return False

        # After mounting, open in nvim
        return open_in_nvim(mountpoint)

    # Device is already mounted, ask what to do
    else:
        actions = [
            f"📂 Browse in nvim|browse",
            f"⏏️  Unmount & Eject|eject"
        ]

        # Use fzf to select action
        try:
            fzf_input = '\n'.join(actions)
            result = subprocess.run(
                ['fzf', '--prompt=Action: ', '--layout=reverse', '--border'],
                input=fzf_input,
                text=True,
                capture_output=True
            )

            if result.returncode != 0 or not result.stdout.strip():
                return False

            selected_action = result.stdout.strip()

            if '|' not in selected_action:
                return False

            action = selected_action.split('|')[1]

            if action == 'browse':
                return open_in_nvim(mountpoint)
            elif action == 'eject':
                return unmount_device(device_path)

        except Exception as e:
            print(f"Error selecting action: {e}")
            return False

    return False
