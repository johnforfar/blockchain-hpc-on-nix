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

      # Added options specific to blockchain/Chainlink setup
      enableDocker = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to enable Docker support for running the local testnet.
        '';
      };

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/xnode-blockchain-hpc";
        description = ''
          Directory to store blockchain and database data.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable Docker if requested
    virtualisation.docker = lib.mkIf cfg.enableDocker {
      enable = true;
      autoPrune.enable = true;
    };

    systemd.services.xnode-blockchain-hpc = {
      wantedBy = [ "multi-user.target" ];
      description = "Blockchain HPC App";
      after = [ "network.target" ] ++ lib.optional cfg.enableDocker "docker.service";
      requires = lib.optional cfg.enableDocker "docker.service";
      
      environment = {
        HOSTNAME = cfg.hostname;
        PORT = toString cfg.port;
        # Add Hardhat/Chainlink specific env vars
        HARDHAT_NETWORK = "localhost";
        DATA_DIR = cfg.dataDir;
      };

      serviceConfig = {
        ExecStartPre = lib.optional cfg.enableDocker "${pkgs.docker-compose}/bin/docker-compose pull";
        ExecStart = "${lib.getExe xnode-blockchain-hpc}";
        ExecStop = lib.optional cfg.enableDocker "${pkgs.docker-compose}/bin/docker-compose down";
        
        # Service configuration
        DynamicUser = true;
        StateDirectory = "xnode-blockchain-hpc";
        CacheDirectory = "hardhat-app";
        
        # Docker access if enabled
        SupplementaryGroups = lib.optional cfg.enableDocker "docker";
        
        # Hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
      };
    };

    # Create data directory
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0750 xnode-blockchain-hpc xnode-blockchain-hpc -"
    ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}