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

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

	home.packages = with pkgs; [
	  claude-code
	  pkgs-unstable.codex
	  ripgrep
	  neovim
	  nil #lsp for nix languages
	  nixpkgs-fmt #formating tool for nix files in the neovim config
	  gcc #used to compile parsers in neovim config
	  nodejs
	  neofetch
    gh
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
