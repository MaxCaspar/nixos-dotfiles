{ config, pkgs, pkgs-unstable, ...}:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    nvim = "nvim";
  };
in

{
	home.username = "maxcaspar";
	home.homeDirectory = "/home/maxcaspar";
	home.stateVersion = "25.11";
	programs.bash = {
		enable = true;
		shellAliases = {
			btw = "echo I use nixOS, btw";
		};
	};
  
  programs.git = {
    enable = true;
    userName = "maxcaspar";
    userEmail = "git@maxcaspar.com";
  };

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      "$mod" = "SUPER";
      terminal = "alacritty";

      exec-once = [
        "waybar"
        "mako"
        "blueman-applet"
        "nm-applet"
        "hyprpolkitagent"
      ];

      bind = [
        "$mod, Return, exec, alacritty"
        "$mod, D, exec, wofi --show drun"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, M, exit"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        ", Print, exec, grimblast copy area"
      ];
    };
  };

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

	home.packages = with pkgs; [
	  # Shell, editor, and development tools.
	  claude-code # Claude Code CLI
	  pkgs-unstable.codex # Codex CLI from unstable nixpkgs
	  ripgrep # fast text search
	  neovim # editor
	  nil # Nix language server
	  nixpkgs-fmt # Nix formatter
	  gcc # C compiler for Neovim parser builds
	  nodejs # JavaScript runtime for tooling
	  gh # GitHub CLI

	  # General system info and monitoring.
	  neofetch # system summary
	  btop # process and system monitor
	  nvitop # NVIDIA GPU monitor

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

    # bash command to rebuild+switch then git commit and push dotfiles 
    (writeShellScriptBin "nixos-switch" ''
      sudo nixos-rebuild switch --flake ~/nixos-dotfiles#hermes
      cd ~/nixos-dotfiles
      git add flake.nix flake.lock configuration.nix hardware-configuration.nix home.nix 
      git commit -m "$1"
      git push
    '')
    # bash command to git commit and push dotfiles
    (writeShellScriptBin "nixos-commit" ''
      cd ~/nixos-dotfiles
      git add flake.nix flake.lock configuration.nix hardware-configuration.nix home.nix 
      git commit -m "$1"
      git push
    '')
	];
}
