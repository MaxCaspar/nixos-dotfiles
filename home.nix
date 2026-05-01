{ config, pkgs, pkgs-unstable, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    nvim = "nvim";
    hypr = "hypr";
    waybar = "waybar";
  };
in

{
  home.username = "maxcaspar";
  home.homeDirectory = "/home/maxcaspar";
  home.stateVersion = "25.11";
  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(starship init bash)"
      [ -z "$IN_NIX_SHELL" ] && fastfetch
    '';
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "maxcaspar";
      email = "git@maxcaspar.com";
    };
  };

  xdg.configFile = (builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs) // {
    "starship.toml".source = create_symlink "${dotfiles}/starship.toml";
  };

  home.packages = with pkgs; [
    # Shell, editor, and development tools.
    claude-code # Claude Code CLI
    pkgs-unstable.codex # Codex CLI from unstable nixpkgs
    starship # shell prompt
    ripgrep # fast text search
    neovim # editor
    nil # Nix language server
    nixpkgs-fmt # Nix formatter
    gcc # C compiler for Neovim parser builds
    nodejs # JavaScript runtime for tooling
    gh # GitHub CLI
    # ns: interactive nix package search using fzf
    (writeShellApplication {
      name = "ns";
      runtimeInputs = [ fzf nix-search-tv ];
      text = builtins.readFile "${nix-search-tv.src}/nixpkgs.sh";
      excludeShellChecks = [ "SC2016" ];
    })

    # General system info and monitoring.
    fastfetch # system info on terminal open
    btop # process and system monitor
    nvitop # NVIDIA GPU monitor
    
    # Programs
    obsidian

    # Hyprland desktop utilities.
    waybar # status bar
    wofi # application launcher
    mako # notification daemon
    grimblast # screenshot helper
    wl-clipboard # clipboard tools for Wayland
    networkmanagerapplet # network tray app
    blueman # Bluetooth manager
    hyprpolkitagent # authentication agent for Hyprland
    pavucontrol # audio mixer
    playerctl # media player control CLI
    brightnessctl # brightness control CLI
    hyprpaper

    # bash command to git commit and push dotfiles
    (writeShellScriptBin "nixos-commit" ''
      set -e
      if [ -z "$1" ]; then
        echo "Forgot the commit message, silly-billy :)"
        exit 1
      fi
      cd ~/nixos-dotfiles
      git add flake.nix flake.lock configuration.nix hardware-configuration.nix home.nix config
      git commit -m "$1"
      git push
    '')
  ];
}
