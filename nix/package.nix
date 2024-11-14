{ pkgs, lib ? pkgs.lib }:
pkgs.buildNpmPackage {
  pname = "xnode-blockchain-hpc";
  version = "1.0.0";
  src = ../hardhat-app;

  npmDepsHash = "sha256-WdydJ8kPJ2I45EAgxqp7Fz6UoAwVjZLXnLoLc8B4qy0=";
  npmFlags = [ "--legacy-peer-deps" ];
  makeCacheWritable = true;

  # Copy node_modules and build files, but don't run build during Nix build
  dontBuild = true;

  nativeBuildInputs = with pkgs; [
    docker
    docker-compose
    nodejs_20
    python3
    yarn
    gnumake    # Added for make commands
  ];

  # Add pre-build step
  preBuild = ''
    make build || true
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{share,bin}
    
    # Copy entire app including node_modules
    cp -r . $out/share/hardhat-app/
    
    # Make scripts executable
    chmod +x $out/share/hardhat-app/scripts/*.sh
    chmod +x $out/share/hardhat-app/modules/*/build.sh

    # Create a wrapped docker-compose command that includes env vars
    makeWrapper ${pkgs.docker-compose}/bin/docker-compose $out/bin/xnode-blockchain-hpc \
      --add-flags "--project-directory $out/share/hardhat-app up" \
      --chdir "$out/share/hardhat-app"

    # Create wrapper for reset-testnet that preserves cwd
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