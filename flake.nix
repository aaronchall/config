{
  description = "This is the manager for all of Aaron's computers.";
  inputs = { ## Three inputs to the flakes:
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
      self, # the directory of this flake in the store
      # and the inputs:
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      ...}:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system; # which means system = system;
          config.allowUnfree = true;
        };
      };
    in { # My system, x1, is the first output, also the hostname, making it default:
      nixosConfigurations.x1 = nixpkgs.lib.nixosSystem {
        inherit system; # again, system = system;
        modules = [ # Seven modules, first is unstable stuff:
          ({ pkgs, ... }: {   # a module with just unstable
              nixpkgs.overlays = [
                overlay-unstable
              ];
              services.ollama = {
                enable = true;
                package = pkgs.unstable.ollama;
              };
              environment.systemPackages = with pkgs; [
                unstable.discord
                unstable.discord-canary
                # see also https://www.reddit.com/r/NixOS/comments/svm500/nixpkgs_overlay_to_have_the_latest_version_of/
              ];
          })
          ./console.nix
          ./gui.nix
          ./x1.nix
          ./programming.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;
            home-manager.users.aaron = { imports = [ ./home.nix ]; };
          }
        ];
      };
      nixosConfigurations.nat = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ # Six modules:
          ({ config, pkgs, ... }: {
              nixpkgs.overlays = [ overlay-unstable ];
              environment.systemPackages = with pkgs; [
                unstable.discord-canary
              ];
          })
          ./console.nix
          ./gui.nix
          ./dad.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;
            home-manager.users.aaron = { imports = [ ./home.nix ]; };
            home-manager.users.nat = { imports = [ ./home.nix ]; };
          }
        ];
      };
      nixosConfigurations.dad = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ # Six modules:
          ({ config, pkgs, ... }: {
              nixpkgs.overlays = [ overlay-unstable ];
              environment.systemPackages = with pkgs; [
                unstable.discord-canary
              ];
          })
          ./console.nix
          ./gui.nix
          ./dad.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;
            home-manager.users.aaron = { imports = [ ./home.nix ]; };
            home-manager.users.steve = { imports = [ ./home.nix ]; };
          }
        ];
      };
      nixosConfigurations.server = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./console.nix
          #./linode.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;
            home-manager.users.aaron = { imports = [ ./home.nix ]; };
          }
        ];
      };
  };
}

