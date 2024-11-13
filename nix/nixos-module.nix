{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.xnode-blockchain-hpc;
  xnode-blockchain-hpc = pkgs.callPackage ./package.nix { };
in
{
  options = {
    services.xnode-blockchain-hpc = {
      enable = lib.mkEnableOption "Enable the blockchain hpc app";

      hostname = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
        example = "127.0.0.1";
        description = ''
          The hostname under which the app should be accessible.
        '';
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        example = 3000;
        description = ''
          The port under which the app should be accessible.
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to open ports in the firewall for this application.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.xnode-blockchain-hpc = {
      wantedBy = [ "multi-user.target" ];
      description = "Blockchain HPC App.";
      after = [ "network.target" ];
      environment = {
        HOSTNAME = cfg.hostname;
        PORT = toString cfg.port;
      };
      serviceConfig = {
        ExecStart = "${lib.getExe xnode-blockchain-hpc}";
        DynamicUser = true;
        CacheDirectory = "hardhat-app";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
