{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }: {
    nixosModules = {
      commonMachineConfig = ./common;
      defaultPkgs = ./pkgs;
    };
    nixosConfigurations = {
      "foxnix" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = with self.nixosModules; [
          commonMachineConfig
          defaultPkgs
          ./machines/foxnix
        ];
      };
      "foxportable" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = with self.nixosModules; [
          commonMachineConfig
          defaultPkgs
          ./machines/foxportable
        ];
      };
    };
  };
}
