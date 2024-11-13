{ pkgs, lib ? pkgs.lib }:
let
  hardhat-src = ../hardhat-app;
in
pkgs.buildNpmPackage {
  pname = "xnode-blockchain-hpc";
  version = "1.0.0";
  
  src = pkgs.runCommand "hardhat-app-src" {} ''
    cp -r ${hardhat-src} $out
    chmod -R +w $out
    cp ${hardhat-src}/package-lock.json $out/package-lock.json
    cp ${hardhat-src}/package.json $out/package.json
  '';

  npmDepsHash = "sha256-0000000000000000000000000000000000000000000=";
  npmFlags = [ "--legacy-peer-deps" ];
  makeCacheWritable = true;

  nativeBuildInputs = with pkgs; [
    docker
    docker-compose
    nodejs_20
    solc
    python3
  ];

  buildPhase = ''
    mkdir -p .hardhat
    npm run build
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