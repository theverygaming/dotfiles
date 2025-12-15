{ flakeInputs, ... }:

{
  custom.wg_mesh.firewall.allowedTCPPorts = [
    9090 # Prometheus
  ];

  # TODO: auth, TLS
  services.prometheus = {
    enable = true;
    port = 9090;

    extraFlags = [
      "--web.enable-remote-write-receiver"
    ];

    # the damn NixOS prometheus module does not allow specifying any options
    # in the storage section of the prometheus.yml..
    # So we need to manually specify the entire fucking file. This is stupid and i'm pissed
    # Of course it is also essentially impossible to override that without patching fucking nixpkgs to my knowledge
    # see: https://github.com/NixOS/nixpkgs/blob/b024ced1aac25639f8ca8fdfc2f8c4fbd66c48ef/nixos/modules/services/monitoring/prometheus/default.nix#L61-L77
    configText = ''
      storage:
        tsdb:
          out_of_order_time_window: 7d
    '';
  };
}
