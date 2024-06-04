import datetime
import time
import os


def executer():
    now = datetime.datetime.now()
    if now.hour < 7 or now.hour >= 23:
        os.system('kill $(ps -A | grep Hyprland)')
        clear_and_cit()

def clear_and_cit():
    os.system('clear')
    os.system('fortune -a | cowsay -W80')



if __name__ == '__main__':
    executer()
    time.sleep(60)

