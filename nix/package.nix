{ pkgs, lib ? pkgs.lib }:
let
  isAarch64Darwin = pkgs.stdenv.system == "aarch64-darwin";
  isx86Darwin = pkgs.stdenv.system == "x86_64-darwin";
  isLinux = pkgs.stdenv.isLinux;

  # Create a hardhat config override
  hardhatConfigOverride = ''
    module.exports = {
      solc: {
        version: "native",
        optimizer: {
          enabled: true,
          runs: 200
        }
      },
      networks: {
        hardhat: {
          chainId: 31337
        }
      }
    };
  '';
in
pkgs.buildNpmPackage {
  pname = "xnode-blockchain-hpc";
  version = "1.0.0";
  src = ../hardhat-app;

  npmDepsHash = "sha256-WdydJ8kPJ2I45EAgxqp7Fz6UoAwVjZLXnLoLc8B4qy0=";
  npmFlags = [ "--legacy-peer-deps" ];
  makeCacheWritable = true;

  nativeBuildInputs = with pkgs; [
    docker
    docker-compose
    nodejs_20
    python3
    solc
  ];

  HARDHAT_OFFLINE = "true";
  HARDHAT_TELEMETRY_OPTOUT = "1";

  # Override the build phase to handle offline compilation
  buildPhase = ''
    mkdir -p .hardhat

    # Create hardhat config override for offline mode
    cat > hardhat.config.override.js << EOF
    ${hardhatConfigOverride}
    EOF

    # Create wrapper script for hardhat that uses our config
    cat > hardhat-wrapper.js << EOF
    #!/usr/bin/env node
    process.env.HARDHAT_CONFIG = require('path').resolve(__dirname, 'hardhat.config.override.js');
    require('hardhat/internal/cli/cli');
    EOF
    chmod +x hardhat-wrapper.js

    # Run the build using our wrapper
    node hardhat-wrapper.js compile --config hardhat.config.override.js
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{share,bin}
    cp -r . $out/share/hardhat-app/
    chmod +x $out/share/hardhat-app/scripts/*.sh

    makeWrapper ${pkgs.nodejs}/bin/npx $out/bin/xnode-blockchain-hpc \
      --add-flags "hardhat node" \
      --set HARDHAT_NETWORK "localhost" \
      --set PORT "3000" \
      --set HOSTNAME "0.0.0.0" \
      --prefix PATH : ${lib.makeBinPath [ pkgs.docker pkgs.docker-compose pkgs.solc ]} \
      --set NODE_PATH "$out/share/hardhat-app/node_modules"

    makeWrapper ${pkgs.bash}/bin/bash $out/bin/reset-testnet \
      --add-flags "$out/share/hardhat-app/scripts/reset-testnet.sh" \
      --prefix PATH : ${lib.makeBinPath [ 
        pkgs.docker 
        pkgs.docker-compose 
        pkgs.nodejs 
        pkgs.yarn
      ]}

    mkdir -p $out/share/hardhat-app/.hardhat
    ln -s /var/cache/hardhat-app $out/share/hardhat-app/.hardhat/cache

    runHook postInstall
  '';

  doDist = false;

  meta = {
    mainProgram = "xnode-blockchain-hpc";
  };
}