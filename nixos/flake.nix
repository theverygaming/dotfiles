{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dns = {
      url = "github:nix-community/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena.url = "github:zhaofengli/colmena";
  };

  outputs = inputs@{ self, ... }: {
    colmena = {
      meta = {
        nixpkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
        };
        specialArgs = {
          flakeInputs = inputs;
        };
      };
      defaults = { name, ... }: {
        imports = [
          ./modules/common
          ./modules/nixos
          ./pkgs/override.nix
          (./. + "/hosts/${name}")
          inputs.home-manager.nixosModules.home-manager
          inputs.disko.nixosModules.disko
        ];
      };
    } // (with inputs.nixpkgs.lib; listToAttrs (map (x: nameValuePair x {}) (attrNames (filterAttrs (x: type: type == "directory") (builtins.readDir ./hosts)))));
    colmenaHive = inputs.colmena.lib.makeHive self.outputs.colmena; # nix run github:zhaofengli/colmena -- apply --on ... --experimental-flake-eval

    nixosConfigurations = (inputs.colmena.lib.makeHive self.outputs.colmena).nodes;
  };
}
