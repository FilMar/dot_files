{ config, pkgs, ... }:

{
  # Waybar configuration
  home-manager.users.fildev = {
    programs.waybar = {
      enable = true;
      settings = [{
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "pulseaudio" "network" "battery#int" "battery#ext" "custom/power" ];

        "hyprland/mode" = {
          format = "<span style=\"italic\">{}</span>";
        };

        network = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ifname} ";
          format-disconnected = "";
          max-length = 50;
          on-click = "ghostty -e nmtui";
        };

        clock = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d}";
        };

        pulseaudio = {
          format = "{volume}% {icon} ";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = "0% {icon} ";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };

        "custom/power" = {
          format = " ";
          on-click = "swaynag -t warning -m 'Power Menu Options' -b 'Logout' 'swaymsg exit' -b 'Restart' 'shutdown -r now' -b 'Shutdown' 'shutdown -h now' --background=#005566 --button-background=#009999 --button-border=#002b33 --border-bottom=#002b33";
        };

        "battery#ext" = {
          bat = "BAT0";
          interval = 60;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-icons = [ "" "" "" "" "" ];
          max-length = 25;
        };

        "battery#int" = {
          bat = "BAT1";
          interval = 60;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-icons = [ "" "" "" "" "" ];
          max-length = 25;
        };

        tray = {
          icon-size = 21;
          spacing = 10;
          show-passive-items = true;
        };
      }];

      style = ''
        * {
          border: none;
          font-family: Font Awesome, Roboto, Arial, sans-serif;
          font-size: 13px;
          color: #ffffff;
          border-radius: 20px;
        }

        window#waybar {
          background: rgba(0, 0, 0, 0);
        }

        .modules-right {
          background-color: rgba(0,43,51,0.85);
          margin: 2px 10px 0 0;
        }

        .modules-center {
          background-color: rgba(0,43,51,0.85);
          margin: 2px 0 0 0;
        }

        .modules-left {
          margin: 2px 0 0 5px;
          background-color: rgba(0,119,179,0.6);
        }

        #workspaces button {
          padding: 1px 5px;
          background-color: transparent;
        }

        #workspaces button:hover {
          box-shadow: inherit;
          background-color: rgba(0,153,153,1);
        }

        #workspaces button.focused {
          background-color: rgba(0,43,51,0.85);
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #temperature,
        #network,
        #pulseaudio,
        #custom-media,
        #tray,
        #mode,
        #custom-power,
        #custom-menu,
        #idle_inhibitor {
          padding: 0 10px;
        }

        #mode {
          color: #cc3436;
          font-weight: bold;
        }

        #custom-power {
          background-color: rgba(0,119,179,0.6);
          border-radius: 100px;
          margin: 5px 5px;
          padding: 1px 1px 1px 6px;
        }

        #idle_inhibitor.activated {
          color: #2dcc36;
        }

        #pulseaudio.muted {
          color: #cc3436;
        }

        #battery.charging {
          color: #2dcc36;
        }

        #battery.warning:not(.charging) {
          color: #e6e600;
        }

        #battery.critical:not(.charging) {
          color: #cc3436;
        }

        #temperature.critical {
          color: #cc3436;
        }
      '';
    };
  };

  # Required packages
  environment.systemPackages = with pkgs; [
    waybar
    pavucontrol
    swaynag
  ];
}