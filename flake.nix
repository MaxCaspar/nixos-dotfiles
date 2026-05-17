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
    pim-src = {
      url = "path:/home/maxcaspar/projects/antiphon/pim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, hermes-agent, home-manager, pim-src, ... }:
    let
      pkgs-unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [
          (final: prev: {
            llama-cpp = prev.llama-cpp.overrideAttrs (old: {
              version = "9186";
              src = prev.fetchFromGitHub {
                owner = "ggml-org";
                repo = "llama.cpp";
                tag = "b9186";
                hash = "sha256-JK9VVgznYkhDt+NGbdT55FIs0uLZAJnZoNfAdUuwsPM=";
                leaveDotGit = true;
                postFetch = ''
                  git -C "$out" rev-parse --short HEAD > $out/COMMIT
                  find "$out" -name .git -print0 | xargs -0 rm -rf
                '';
              };
              npmRoot = "tools/ui";
              npmDepsHash = "sha256-WaEePrEZ7O/7deP2KJhe0AwiSKYA8HOqETmMHUkmBe0=";
            });
          })
        ];
      };
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
              extraSpecialArgs = { inherit pkgs-unstable pim-src; };
            };
          }
        ];
      };
    };
}
