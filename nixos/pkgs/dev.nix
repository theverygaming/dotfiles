{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    arduino
    gh # GitHub CLI
    git
    python311
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions;
        [
          ms-vscode.cpptools
          jnoortheen.nix-ide
          twxs.cmake
          gruntfuggly.todo-tree
          mhutchie.git-graph
          ms-vscode.hexeditor
          yzhang.markdown-all-in-one
          ritwickdey.liveserver
          denoland.vscode-deno
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "remote-containers";
            publisher = "ms-vscode-remote";
            version = "0.346.0";
            sha256 = "sha256-v36nuM+TrStTIuw0qV/8IkYlauyFTRmKQZ60ve0jVsA=";
          }
          {
            name = "python";
            publisher = "ms-python";
            version = "2024.1.10531008";
            sha256 = "sha256-HNmHp5iLVNH0HOwEr5sUhnFbSqnfTN0EHxM4P+7l/X8=";
          }
          {
            name = "VerilogHDL";
            publisher = "mshr-h";
            version = "1.13.2";
            sha256 = "sha256-MOU8zf2qS7P2pQ29w3mvhDc2OvZiH4HNe530BjIiRAA=";
          }
          {
            name = "vscode-scl";
            publisher = "Gunders89";
            version = "0.0.21";
            sha256 = "sha256-mPiwieHGeSJNAU88X59AlmEYS5Jy3UFA3h85RNMwBn0=";
          }
          {
            name = "discord-vscode";
            publisher = "icrawl";
            version = "5.8.0";
            sha256 = "sha256-IU/looiu6tluAp8u6MeSNCd7B8SSMZ6CEZ64mMsTNmU=";
          }
          {
            name = "vscode-mlir";
            publisher = "llvm-vs-code-extensions";
            version = "0.0.11";
            sha256 = "sha256-slu3Ri8U0ZthHidmd18jcmogPudzvXxqhpmo8AWmsvw=";
          }
          {
            name = "vscode-latex";
            publisher = "mathematic";
            version = "1.3.0";
            sha256 = "sha256-/mbMpel9JHmSh0GN/wIbFi/0voaQBxGn0SueZlUFZUc=";
          }
          {
            name = "mako";
            publisher = "tommorris";
            version = "0.2.0";
            sha256 = "sha256-Ss5s2fTY+Q/09LQpNWaaYboUgzouJ7OnjJBKtPkonm8=";
          }
        ];
    })
    clang-tools_16
    verible # verilog formatting
    nixpkgs-fmt # nix formatting
  ];
  virtualisation.docker.enable = true; # for devcontainers
}
