#!/usr/bin/env python

import subprocess

def run_hyprctl(command):
    subprocess.run(['hyprctl'] + command.split(), capture_output=True)

def get_mfact_value():
    result = subprocess.run(['hyprctl', 'getoption', 'master:mfact'], capture_output=True, text=True)
    try:
        return float(result.stdout.strip().split()[1])
    except (IndexError, ValueError):
        return 0.7 # Default to 0.7 if parsing fails

def main():
    if get_mfact_value() == 0.7:
        # Enable focus mode: increase master window size and dim inactive
        run_hyprctl('--batch keyword master:mfact 0.95; keyword decoration:dim_inactive true; keyword decoration:dim_strength 0.5')
    else:
        # Disable focus mode: restore normal size and remove dimming  
        run_hyprctl('--batch keyword master:mfact 0.7; keyword decoration:dim_inactive false')

if __name__ == '__main__':
    main()
