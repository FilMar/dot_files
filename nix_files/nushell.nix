{ config, pkgs, ... }:

{
  # Nushell configuration
  home-manager.users.fildev = {
    programs.nushell = {
      enable = true;
      
      # Main configuration
      configFile.source = ../nu_files/config.nu;
      envFile.source = ../nu_files/env.nu;
      
      # Shell aliases (can also be managed via configFile)
      shellAliases = {
        # Basic system aliases
        cp = "cp -i";
        df = "df -h";
        free = "free -m";
        vim = "nvim";
        vid = "nvim .";
        batInfo = "sudo tlp-stat -b";
        tree = "tree -C";
        py = "python3";
        
        # Modern replacements
        cat = "bat";
        ls = "exa -l";
        la = "exa -lah";
        
        # Git aliases
        gitu = "git add . && git commit && git push";
        gith = "git log --graph --oneline";
        ngit = "nvim -c Neogit";
        
        # SSH
        ssmax = "ssh -i ~/.ssh/LightsailDefaultKey-eu-west-3.pem ubuntu@35.181.223.102";
      };
    };

    # Starship prompt for modern styling (alternative to typewritten)
    programs.starship = {
      enable = true;
      settings = {
        format = "$all$character";
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vimcmd_symbol = "[❮](bold green)";
        };
        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
          style = "bold cyan";
        };
        git_branch = {
          symbol = " ";
          style = "bold purple";
        };
        git_status = {
          style = "bold yellow";
        };
        cmd_duration = {
          min_time = 2000;
          format = "[$duration](bold yellow)";
        };
      };
    };

    # FZF integration
    programs.fzf = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
    };
  };

  # System packages needed for the converted functions
  environment.systemPackages = with pkgs; [
    nushell
    starship
    
    # Tools used in converted functions
    fd
    fzf
    bat
    exa
    docker
    
    # Development tools
    git
    neovim
  ];
}