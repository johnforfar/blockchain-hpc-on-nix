#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR/..

# This is a test environment that uses the hardhat local accounts
export TESTNET_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff08
export MAINNET_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export ETH_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export NODE_URL=http://localhost:8545/
export FEED_REGISTRY_ADDRESS=0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
export ETH_CALLER=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
export TOKEN_HPC=0x5FbDB2315678afecb367f032d93F642f64180aa3
export OPERATOR_HPC=0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
export JOBID_HPC=a3fa982792ad486785be5d89ac333ab5

# Define a function to clean up and kill all children
cleanup_and_exit() {
    echo "Interrupted. Killing all child processes."
    pgrep -P $$ | xargs kill
}

(npx hardhat node --hostname 0.0.0.0) &

echo "node started waiting...."
sleep 3
(npx hardhat --network localhost run ./scripts/deploy-token.ts)
(npx hardhat --network localhost run ./scripts/deploy-operator.ts)
(npx hardhat --network localhost run ./scripts/deploy-example.ts)

# Trap interrupts and call our cleanup function
trap "cleanup_and_exit" INT  # Ctrl+C

sleep infinity

