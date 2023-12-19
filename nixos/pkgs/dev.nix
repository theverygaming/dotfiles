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
            name = "vscode-scl";
            publisher = "Gunders89";
            version = "0.0.21";
            sha256 =
              "98f8b089e1c679224d014f3c5f9f409661184b9272dd4140de1f3944d330067d";
          }
          {
            name = "VerilogHDL";
            publisher = "mshr-h";
            version = "1.11.11";
            sha256 = "sha256-YzJxWVBkqz180vEU4WRHQL2GU3RpiqGnlkHNskI68Uo=";
          }
          {
            name = "discord-vscode";
            publisher = "icrawl";
            version = "5.8.0";
            sha256 = "sha256-IU/looiu6tluAp8u6MeSNCd7B8SSMZ6CEZ64mMsTNmU=";
          }
          {
            name = "teroshdl";
            publisher = "teros-technology";
            version = "5.0.11";
            sha256 = "sha256-9ng2MQ7XZtM+Az9WHY+/ZYrbROEDbHQDXm07JW3Kvk8=";
          }
          {
            name = "lex";
            publisher = "luniclynx";
            version = "0.1.0";
            sha256 = "sha256-yZEo28yWiLDL5AyL7yejpdJ7ISHl2gIjhPMWgf2tCgk=";
          }
          {
            name = "bison";
            publisher = "luniclynx";
            version = "0.1.0";
            sha256 = "sha256-zauCtFiB1RcoV8W4zg2D63mLRDbMTWVleI/cbzFEdpY=";
          }
          {
            name = "vscode-mlir";
            publisher = "llvm-vs-code-extensions";
            version = "0.0.11";
            sha256 = "sha256-slu3Ri8U0ZthHidmd18jcmogPudzvXxqhpmo8AWmsvw=";
          }
          {
            name = "python";
            publisher = "ms-python";
            version = "2023.18.0";
            sha256 = "sha256-Ai2V3IZvNdb3R/HdAWXy+BBvmgl9g3+9VN3RZMF5uG8=";
          }
          {
            name = "vscode-latex";
            publisher = "mathematic";
            version = "1.3.0";
            sha256 = "sha256-/mbMpel9JHmSh0GN/wIbFi/0voaQBxGn0SueZlUFZUc=";
          }
          {
            name = "remote-containers";
            publisher = "ms-vscode-remote";
            version = "0.321.0";
            sha256 = "sha256-lgTikqIwrf1xhxP+XGQCtl2xzOGWYRlhEoh/Z8H5Jl0=";
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
