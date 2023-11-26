{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ kubectx kubectl kubernetes-helm ];
}
