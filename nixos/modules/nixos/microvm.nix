{
  config,
  lib,
  flakeInputs,
  pkgs,
  ...
}:

# FIXME: microvm dir is fckin world-readable sobbbb

let
  cfg = config.custom.microvm;
in
{
  options.custom.microvm = with lib; {
    enable = mkEnableOption "Enables the WireGuard mesh";
    hostIp = mkOption {
      type = types.str;
      default = "10.69.0.1";
      description = ''
        IP of the host for the VM bridge
      '';
    };
    prefixLength = mkOption {
      type = types.int;
      default = 24;
      description = ''
        subnet mask prefix length for the guest network 
      '';
    };
    vms = mkOption {
      type = types.attrsOf (
        types.submodule (
          { ... }:
          {
            options = {
              id = mkOption {
                type = types.str;
                description = ''
                  Identifier of the VM
                  currently used for interface names
                '';
              };

              ip = mkOption {
                type = types.str;
                description = ''
                  IP of the VM
                '';
              };

              modules = mkOption {
                type = types.listOf types.raw;
                default = [ ];
                description = ''
                  NixOS modules for the VM
                '';
              };

              extraConfig = mkOption {
                type = types.attrs;
                default = { };
                description = ''
                  Extra configuration passed to the microvm
                '';
              };

              insecureDebug = mkOption {
                type = types.bool;
                default = false;
                description = ''
                  Enable insecure debugging (ssh with password 12345678)
                '';
              };

              host_share = mkOption {
                type = types.bool;
                default = false;
                description = ''
                  If a host share (VM:/host_share -> HOST:/var/lib/microvms/<vm name>/host_share)
                  should be created for this VM or not
                '';
              };
            };
          }
        )
      );
      description = "VMs";
    };
  };

  config = lib.mkIf cfg.enable ({
    # FIXME: when a VM is removed from the config, it won't get stopped... :skull:
    microvm.vms = lib.mapAttrs (
      name: vm:
      {
        pkgs = import flakeInputs.nixpkgs { system = pkgs.stdenv.hostPlatform.system; };
        config =
          { ... }:
          {
            imports =
              vm.modules
              ++ (
                if vm.insecureDebug then
                  lib.warn "DANGEROUS: Insecure debugging enabled for microvm ${name}" [
                    (
                      { ... }:
                      {
                        users.users."user" = {
                          isNormalUser = true;
                          description = "user";
                          extraGroups = [
                            "wheel"
                          ];
                          initialPassword = "12345678";
                        };

                        services.openssh = {
                          enable = true;
                          settings.PermitRootLogin = "yes";
                          settings.PasswordAuthentication = true;
                        };

                        networking.firewall.allowedTCPPorts = [
                          22
                        ];
                      }
                    )

                  ]
                else
                  [ ]
              );

            microvm = {
              hypervisor = "crosvm";

              balloon = true;

              interfaces = [
                {
                  type = "tap";
                  # interface name on the host
                  id = "tap-mvm-${vm.id}";
                  mac = "02:00:00:00:00:01";
                }
              ];

              shares =
                [
                  {
                    source = "/nix/store";
                    mountPoint = "/nix/.ro-store";
                    tag = "ro-store";
                    proto = "virtiofs";
                  }
                ]
                ++ (
                  if vm.host_share then
                    [
                      {
                        proto = "virtiofs";
                        tag = "host_share";
                        source = "/var/lib/microvms/${name}/host_share";
                        mountPoint = "/host_share";
                      }
                    ]
                  else
                    [ ]
                );
            };

            networking.interfaces.eth0.ipv4.addresses = [
              {
                address = vm.ip;
                prefixLength = cfg.prefixLength;
              }
            ];

            # Guess what, systemd naming is ass here
            boot.kernelParams = [
              "net.ifnames=0"
            ];

            users.mutableUsers = false; # DECLARATIVE USERS!! :3
          };
      }
      // vm.extraConfig
    ) cfg.vms;

    systemd.services = builtins.foldl' (
      result: name:
      result
      // (
        if cfg.vms.${name}.host_share then
          {
            "install-microvm-${name}-host-share" = {
              description = "Create host share";
              wantedBy = [ "install-microvm-${name}.service" ];
              before = [ "install-microvm-${name}.service" ];
              script = ''
                mkdir -p "/var/lib/microvms/${name}/host_share"
                chown -hR microvm:kvm "/var/lib/microvms/${name}/host_share"
              '';
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
              };
            };
          }
        else
          { }
      )
    ) { } (builtins.attrNames cfg.vms);

    # systemd-networkd automatically enables systemd-resolved which we DO NOT want especially on servers that run nameservers..
    services.resolved.enable = false;
    systemd.network = {
      enable = true;
      wait-online.enable = false; # systemd-networkd does not handle our connection to the internet so this would be broken otherwise
      netdevs.virbr0.netdevConfig = {
        Kind = "bridge";
        Name = "virbr0";
      };
      networks.virbr0 = {
        matchConfig.Name = "virbr0";

        addresses = [
          {
            Address = "${cfg.hostIp}/${builtins.toString cfg.prefixLength}";
          }
        ];
      };
      networks.microvms = {
        matchConfig.Name = "tap-mvm-*";
        networkConfig.Bridge = "virbr0";
      };
    };
  });
}
