{
  description = "Sigurd's NixOS Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    bash-utils = {
      url = "github:Unigurd/bash-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    isd = {
      url = "github:isd-project/isd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waveforms = {
      url = "github:liff/waveforms-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixos-hardware,
    nur,
    home-manager,
    bash-utils,
    isd,
    waveforms,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    specialArgs = {
      inherit self;
      inherit inputs;
      nurpkgs = nur.legacyPackages.${system};
      isd = isd.packages.${system};
    };
  in
    {
      nixosConfigurations = {
        "gurd-personal" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = specialArgs;
          modules = [
            ./gurd-personal/configuration.nix
            ./gurd-personal/hardware-configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-t480s
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.gurd = import ./gurd-personal/home.nix;
              home-manager.backupFileExtension = "backup";
              # To pass inputs on to home.nix
              home-manager.extraSpecialArgs = specialArgs;
            }
            waveforms.nixosModule
          ];
        };

        "gurd-server" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = specialArgs;
          modules = [
            ./gurd-server/configuration.nix
            ./gurd-server/hardware-configuration.nix
          ];
        };
      };

      # For gurd-server
      homeConfigurations = {
        "gurd" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [gurd-server/home.nix];
          extraSpecialArgs = specialArgs;
        };
        "sson" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [sson/home.nix];
          extraSpecialArgs = specialArgs;
        };
      };
      defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
    }
    // (import ./lib/python/python.nix {inherit pkgs;});
}
