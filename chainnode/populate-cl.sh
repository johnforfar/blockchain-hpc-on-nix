#!/bin/bash
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
docker compose exec link-main-node chainlink admin login -f /chainlink/.api
docker compose exec link-main-node chainlink admin status
docker compose exec link-main-node chainlink bridges create '{
  "name": "executor",
  "url": "http://executor:8000/api1",
  "confirmations": 1,
  "minimumContractPayment": "0"
}'
docker compose exec link-main-node chainlink jobs create /chainlink/chainnode/node-api1.toml

export OPERATOR_HPC=0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
export NODE_ETH_ADDRESS=`docker compose exec link-main-node chainlink keys eth list | grep Address: | awk '{print $2}'`
npx hardhat run $SCRIPT_DIR/../scripts/set-authorized-senders.ts
