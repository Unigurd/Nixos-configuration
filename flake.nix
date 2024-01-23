{
  description = "Sigurd's NixOS Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    bash-utils = {
      url = "github:Unigurd/bash-utils";
      # "/home/gurd/bash/bash-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{self, nixpkgs, nixos-hardware, bash-utils}: {
    nixosConfigurations = {
      "nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./configuration.nix
          # ./hardware-configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t480s
        ];
      };
    };
  };
}
