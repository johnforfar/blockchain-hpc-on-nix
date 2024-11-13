{ pkgs, lib ? pkgs.lib }:
pkgs.buildNpmPackage {
  pname = "xnode-blockchain-hpc";
  version = "1.0.0";
  src = ../hardhat-app;

  # FIXME: this needs to be updated every time the package-lock.json changes
  npmDepsHash = "sha256-SkoL9YyFxV9IFX81SBSKeLmpYNBMSrMSKMkSrUcnlMM=";

  # Use fakeHash to get the correct hash
  # npmDepsHash = lib.fakeHash;

  # Add these lines to handle the dependency issues
  npmFlags = [ "--legacy-peer-deps" ];
  makeCacheWritable = true;

  nativeBuildInputs = with pkgs; [
    docker
    docker-compose
    nodejs_20  # Ensure we use a compatible Node.js version
    solc       # Solidity compiler
    python3    # Required for some node-gyp builds
  ];

  buildPhase = ''
    # Ensure the Hardhat cache directory exists
    mkdir -p .hardhat

    # Run the build script from package.json
    npm run build
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{share,bin}

    # Copy the entire app directory
    cp -r . $out/share/hardhat-app/

    # Make scripts executable
    chmod +x $out/share/hardhat-app/scripts/*.sh

    # Create wrapper for the main hardhat app
    makeWrapper ${pkgs.nodejs}/bin/npx $out/bin/xnode-blockchain-hpc \
      --add-flags "hardhat node" \
      --set HARDHAT_NETWORK "localhost" \
      --set PORT "3000" \
      --set HOSTNAME "0.0.0.0" \
      --prefix PATH : ${lib.makeBinPath [ pkgs.docker pkgs.docker-compose pkgs.solc ]} \
      --set NODE_PATH "$out/share/hardhat-app/node_modules"

    # Create wrapper for reset-testnet script
    makeWrapper ${pkgs.bash}/bin/bash $out/bin/reset-testnet \
      --add-flags "$out/share/hardhat-app/scripts/reset-testnet.sh" \
      --prefix PATH : ${lib.makeBinPath [ 
        pkgs.docker 
        pkgs.docker-compose 
        pkgs.nodejs 
        pkgs.yarn
      ]}

    # Create cache directory for hardhat
    mkdir -p $out/share/hardhat-app/.hardhat
    ln -s /var/cache/hardhat-app $out/share/hardhat-app/.hardhat/cache

    runHook postInstall
  '';

  doDist = false;

  meta = {
    mainProgram = "xnode-blockchain-hpc";
  };
}