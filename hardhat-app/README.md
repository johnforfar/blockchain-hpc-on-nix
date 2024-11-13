# Blockchain Distributed Computation Using Chainlink

This project is a basic example of blockchain distributed computation using
Chainlink.  This system starts up a local blockchain which then distributes
work to various nodes.

To run:

./scripts/reset-testnet.sh - sets up a clean test net
EXAMPLE_CONTRACT=0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9 npx hardhat run scripts/ping.ts --network localhost
