{
  description = "NixOS birth of Hermes";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, hermes-agent, home-manager, ... }:
    let
      pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
    in
    {
      nixosConfigurations.hermes = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit pkgs-unstable; };
        modules = [
          ({ config, pkgs, ... }: { nixpkgs.config.allowUnfree = true; })
          hermes-agent.nixosModules.default
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.maxcaspar = import ./home.nix;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit pkgs-unstable; };
            };
          }
        ];
      };
    };
}
