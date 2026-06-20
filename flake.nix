{
  description = "This is the manager for all of Aaron's computers.";
  inputs = { ## four inputs to my flake - flakes by default but can set flake = false; to override:
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      # .follows overrides input to hm's flake with above (see flake.lock)
      inputs.nixpkgs.follows = "nixpkgs"; # avoiding nixpkgs duplication in /nix/store
    };
    sops-nix = { # secret ops, mostly to encrypt wifi passwords on my system
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
      # self is the directory of this flake in the store,  four inputs:
      self, nixpkgs, nixpkgs-unstable, home-manager, sops-nix, ...}:
    let
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      ollama_module = ({ pkgs, ... }: {   # a module with just unstable
        nixpkgs.overlays = [
          overlay-unstable
        ];
        services.ollama = {
          enable = false; # below pulled on service launch!
          package = pkgs.unstable.ollama;
          loadModels = [ # Size, Context
            "mistral"    # 4.4 GB, 32K
          ];
        };
      });
      my_home = {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;
            home-manager.users.aaron = { imports = [ ./home.nix ]; };
      };
    in { # My system, x1, is the first output, also the hostname, making it default:
      nixosConfigurations.x1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ # ten modules, first is unstable stuff:
          ollama_module
          ./console.nix
          ./gui.nix
          ./x1.nix
          ./programming.nix
          sops-nix.nixosModules.sops
          ./networking.nix
          ./virtualization.nix
          home-manager.nixosModules.home-manager
          my_home
        ];
      };
      nixosConfigurations.idea = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./console.nix
          ./nat.nix
        ];
      };
      nixosConfigurations.homelab = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./console.nix
          ./programming.nix
          ./homelab.nix
          ({ pkgs, ... }: {
            nixpkgs.overlays = [ overlay-unstable ];
            services.ollama = {
              enable = true; # below pulled on service launch!
              package = pkgs.unstable.ollama;
              loadModels = [ # Size, Context, Input
                "mistral" # 4.4 GB, 32K, Text
                "qwen3.6" # 24 GB, 256K, Text/Image
                "qwen3.6:35b-a3b-mtp-bf16" # 72 GB, 256K, Text/Image
              ];
            };
          })
          home-manager.nixosModules.home-manager
          my_home
        ];
      };
      nixosConfigurations.dad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
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
        system = "x86_64-linux";
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

