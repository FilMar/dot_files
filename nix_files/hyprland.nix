{ config, pkgs, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Hyprland configuration
  home-manager.users.fildev = {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        # Monitor setup
        monitor = [
          "DP-1,1920x1080@60,0x0,auto,transform,0"
          "HDMI-A-2,1920x1080@60,auto,auto,transform,0"
        ];

        # Environment variables
        env = [
          "XCURSOR_SIZE,24"
        ];

        # Autostart applications
        exec-once = [
          "waybar"
          "wired"
          "mega-sync"
          "swww init"
          "emacs --daemon"
        ];

        # Input configuration
        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = false;
          };
          sensitivity = 0;
        };

        # General settings
        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
        };

        # Decoration settings
        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };
        };

        # Animations (disabled)
        animations = {
          enabled = false;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        # Layout settings
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        # Gestures
        gestures = {
          workspace_swipe = false;
        };

        # Variables
        "$mainMod" = "ALT";
        
        # Key bindings
        bind = [
          "$mainMod, RETURN, exec, ghostty"
          "$mainMod SHIFT, RETURN, exec, emacsclient -c --eval \"(multi-vterm)\""
          "$mainMod, N, exec, obsidian"
          "$mainMod, Q, killactive"
          "$mainMod SHIFT, Q, exit"
          "$mainMod, V, togglefloating"
          "$mainMod, F, fullscreen"
          "$mainMod, P, exec, wofi --show drun"
          
          # Focus movement
          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"
          
          # Window movement
          "$mainMod SHIFT, h, movewindow, l"
          "$mainMod SHIFT, l, movewindow, r"
          "$mainMod SHIFT, k, movewindow, u"
          "$mainMod SHIFT, j, movewindow, d"
          
          # Resize submap
          "$mainMod, R, submap, resize"
        ] ++ (
          # Generate workspace bindings 1-10
          builtins.concatLists (builtins.genList (
            x: let
              ws = let
                c = (x + 1) / 10;
              in
                builtins.toString (x + 1 - (c * 10));
            in [
              "$mainMod, ${ws}, workspace, ${toString (x + 1)}"
              "$mainMod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          ) 10)
        ) ++ [
          # Mouse scroll workspaces
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
        ];

        # Repeatable resize bindings (for resize submap)
        binde = [
          ", l, resizeactive, 10 0"
          ", h, resizeactive, -10 0"
          ", k, resizeactive, 0 -10"
          ", j, resizeactive, 0 10"
          ", escape, submap, reset"
        ];

        # Mouse bindings
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        # Submaps definition
        submap = [
          "resize"
          "reset"
        ];
      };
    };
  };

  # Required packages
  environment.systemPackages = with pkgs; [
    hyprland
    waybar
    wofi
    ghostty
    swww
  ];
}