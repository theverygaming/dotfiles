{ home-manager, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # extraSpecialArgs = { inherit plasma-manager; };
  };
}
