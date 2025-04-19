{ pkgs, ... }:

(
  with pkgs.lib;
  listToAttrs (
    map (x: nameValuePair x (pkgs.callPackage (./. + "/${x}") { })) (
      attrNames (filterAttrs (x: type: type == "directory") (builtins.readDir ./.))
    )
  )
)
