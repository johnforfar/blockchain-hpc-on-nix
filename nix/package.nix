{ pkgs, lib ? pkgs.lib }:
pkgs.buildNpmPackage {
  pname = "xnode-blockchain-hpc";
  version = "1.0.0";
  src = ../hardhat-app;

  npmDepsHash = "sha256-WdydJ8kPJ2I45EAgxqp7Fz6UoAwVjZLXnLoLc8B4qy0=";
  npmFlags = [ "--legacy-peer-deps" ];
  makeCacheWritable = true;

  dontBuild = true;

  nativeBuildInputs = with pkgs; [
    docker
    docker-compose
    nodejs_20
    python3
    yarn
    gnumake
  ];

  preBuild = ''
    make build || true
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{share,bin}
    mkdir -p $out/share/hardhat-app/runtime/chainlink
    
    # Copy entire app including node_modules
    cp -r . $out/share/hardhat-app/
    
    # Create default chainlink config files if they don't exist
    touch $out/share/hardhat-app/runtime/chainlink/password
    touch $out/share/hardhat-app/runtime/chainlink/secrets.toml
    touch $out/share/hardhat-app/runtime/chainlink/config.toml
    touch $out/share/hardhat-app/runtime/chainlink/api
    
    # Make sure the chainlink directory and files are accessible
    chmod -R 755 $out/share/hardhat-app/runtime

    # Make scripts executable
    chmod +x $out/share/hardhat-app/scripts/*.sh
    chmod +x $out/share/hardhat-app/modules/*/build.sh

    # Create a wrapped docker-compose command
    makeWrapper ${pkgs.docker-compose}/bin/docker-compose $out/bin/xnode-blockchain-hpc \
      --add-flags "--project-directory $out/share/hardhat-app up" \
      --chdir "$out/share/hardhat-app" \
      --set CHAINLINK_CONFIG_DIR "$out/share/hardhat-app/runtime/chainlink"

    # Create wrapper for reset-testnet
    makeWrapper ${pkgs.bash}/bin/bash $out/bin/reset-testnet \
      --add-flags "$out/share/hardhat-app/scripts/reset-testnet.sh" \
      --prefix PATH : ${lib.makeBinPath [ 
        pkgs.docker 
        pkgs.docker-compose 
        pkgs.nodejs 
        pkgs.yarn
        pkgs.gnumake
      ]} \
      --chdir "$out/share/hardhat-app"

    # Create convenience wrappers for npm scripts
    makeWrapper ${pkgs.yarn}/bin/yarn $out/bin/hardhat-build \
      --add-flags "build" \
      --chdir "$out/share/hardhat-app"

    makeWrapper ${pkgs.yarn}/bin/yarn $out/bin/hardhat-test \
      --add-flags "test" \
      --chdir "$out/share/hardhat-app"

    makeWrapper ${pkgs.yarn}/bin/yarn $out/bin/hardhat-lint \
      --add-flags "lint" \
      --chdir "$out/share/hardhat-app"

    # Create make command wrapper
    makeWrapper ${pkgs.gnumake}/bin/make $out/bin/blockchain-make \
      --prefix PATH : ${lib.makeBinPath [
        pkgs.docker
        pkgs.docker-compose
        pkgs.nodejs
        pkgs.yarn
        pkgs.gnumake
      ]} \
      --chdir "$out/share/hardhat-app"

    runHook postInstall
  '';

  doDist = false;

  meta = {
    mainProgram = "xnode-blockchain-hpc";
    description = "Blockchain HPC with Hardhat and Chainlink";
    platforms = pkgs.lib.platforms.unix;
  };
}