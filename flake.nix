{
  description = "This is the manager for all of Aaron's computers.";
  inputs = { ## Three inputs to the flakes:
    # swapped below when approaching 25.11 release but it wasn't available yet
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      #url = "github:nix-community/home-manager/master";
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
      self, # the directory of this flake in the store
      # and the three inputs:
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
                enable = true; # below pulled on service launch!
                package = pkgs.unstable.ollama;
                loadModels = [ # Size, Context
                  "mistral" # 4.4 GB, 32K
                  #"smollm2" # 1.8 GB, 8K
                  #"granite" # 2.1 GB, 128K
                  #"granite4:350m-h" # 366 MB, 1M
                  #"granite4:7b-a1b-h" # 4.2 GB, 1M
                ];
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
      nixosConfigurations.idea = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./console.nix
          ./nat.nix
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

