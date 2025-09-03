#!/usr/bin/env python

import subprocess

def run_hyprctl(command):
    subprocess.run(['hyprctl'] + command.split(), capture_output=True)

def get_dim_value():
    result = subprocess.run(['hyprctl', 'getoption', 'decoration:inactive_dim'], capture_output=True, text=True)
    # Output is like: "float: 0.000000"
    try:
        return float(result.stdout.strip().split()[1])
    except (IndexError, ValueError):
        return 0.0 # Default to 0.0 if parsing fails

def main():
    if get_dim_value() == 0.0:
        run_hyprctl('--batch keyword decoration:inactive_dim 0.8; keyword master:mfact 0.9')
    else:
        run_hyprctl('--batch keyword decoration:inactive_dim 0.0; keyword master:mfact 0.7')

if __name__ == '__main__':
    main()
