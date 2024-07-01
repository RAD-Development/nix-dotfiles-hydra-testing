{ lib, config, ... }:
let
  cfg = config.services.rad-dev.k3s-net;
in
{
  options = {
    services.rad-dev.k3s-net = {
      enable = lib.mkOption {
        default = true;
        example = true;
        description = "Whether to enable k3s-net.";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    system.activationScripts.setZerotierName = lib.stringAfter [ "var" ] ''
      echo "ebe7fbd44565ba9d=ztkubnet" > /var/lib/zerotier-one/devicemap 
    '';

    services.zerotierone = lib.mkDefault {
      enable = true;
      joinNetworks = [ "ebe7fbd44565ba9d" ];
    };

    systemd.network = lib.mkDefault {
      enable = true;
      wait-online.anyInterface = true;
      netdevs = {
        "20-brkubnet" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "brkubnet";
          };
        };
      };
      networks = {
        "30-ztkubnet" = {
          matchConfig.Name = "ztkubnet";
          networkConfig.Bridge = "brkubnet";
          linkConfig.RequiredForOnline = "enslaved";
        };
        "40-brkubnet" = {
          matchConfig.Name = "brkubnet";
          bridgeConfig = { };
          linkConfig.RequiredForOnline = "no";
        };
      };
    };

    # enable experimental networkd backend so networking doesnt break on hybrid systems
    networking.useNetworkd = lib.mkDefault true;
  };
}
