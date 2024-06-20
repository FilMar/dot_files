import datetime
import time
import os

already_executed = False


def executer():
    now = datetime.datetime.now()
    if now.hour < 8 or now.hour >= 23:
        os.system('kill $(ps -A | grep Hyprland)')
        clear_and_cit()


def clear_and_cit():
    global already_executed
    if already_executed:
        return
    os.system('clear')
    os.system('fortune -a | cowsay -W80')
    already_executed = True


if __name__ == '__main__':
    while True:
        executer()
        time.sleep(3 * 60 * 60)
