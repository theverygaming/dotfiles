{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }: {
    nixosModules = {
      declarativeHome = { ... }: {
        # big thank you to https://determinate.systems/posts/declarative-gnome-configuration-with-nixos !!!
        imports = [ home-manager.nixosModules.home-manager ];
        config = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        };
      };
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
          declarativeHome
          ./users/user
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
