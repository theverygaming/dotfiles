{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kubectx
    kubectl
    kubernetes-helm
    # Nixpkgs argocd is borked (https://github.com/NixOS/nixpkgs/issues/207618), argocd provides a static binary so lets just use that instead! :3c
    (stdenvNoCC.mkDerivation (args: rec {
      pname = "argocd";

      version = "2.11.8";

      src = fetchurl {
        url = "https://github.com/argoproj/argo-cd/releases/download/v${version}/argocd-linux-amd64";
        hash = "sha256-94XP5b2OOZr34AnVjGeq5k/P7XuQeAfurvUTafFw3Co=";
      };

      unpackPhase = ''
        runHook preUnpack

        cp $src argocd-linux-amd64

        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall

        install -D argocd-linux-amd64 $out/bin/argocd

        runHook postInstall
      '';
    }))
    kubeseal
  ];
}
