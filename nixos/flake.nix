{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #plasma-manager = {
    #  url = "github:pjones/plasma-manager";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.home-manager.follows = "home-manager";
    #};
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, /* plasma-manager, */ ... }: {
    nixosModules = {
      declarativeHome = { ... }: {
        # big thank you to https://determinate.systems/posts/declarative-gnome-configuration-with-nixos !!!
        imports = [ home-manager.nixosModules.home-manager ];
        config = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          #home-manager.extraSpecialArgs = { inherit plasma-manager; };
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
          ./configs/gnome.nix
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
          ./configs/i3.nix
          ./machines/foxportable
          declarativeHome
          ./users/user
        ];
      };
    };
  };
}
