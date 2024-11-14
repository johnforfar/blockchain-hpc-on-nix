# Blockchain Distributed Computation Using Chainlink

This project demonstrates blockchain distributed computation using Chainlink. The system initializes a local blockchain that distributes work across various nodes.

## Prerequisites

- Nix package manager with flakes enabled
- Docker
- Docker Compose

## Quick Start

```bash
# Build required multi-arch services (needed for ARM64/x86)
make build

# Start the application
make run

# Reset and initialize a clean testnet
make reset
```

## Development Setup

### Using Nix (Recommended)
```bash
# Start the application
nix run

# Reset and initialize a clean testnet
nix run .#reset-testnet

# Update dependencies hash (when package.json changes)
nix build .#xnode-blockchain-hpc --impure
```

### Using Docker Directly (from /hardhat-app folder)
```bash
# Reset and initialize a clean testnet
./scripts/reset-testnet.sh

# Run the ping example (after testnet is initialized)
EXAMPLE_CONTRACT=0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9 npx hardhat run scripts/ping.ts --network localhost
```

## Project Structure

```
.
├── hardhat-app/          # Main application code
│   ├── contracts/        # Solidity smart contracts
│   ├── modules/          # Service modules
│   │   ├── chainlink/   # Chainlink node service
│   │   ├── executor/    # Executor service
│   │   ├── quantragrpc/ # Quantra gRPC service
│   │   └── rpc-failover/# RPC failover service
│   ├── scripts/         # Deployment and utility scripts
│   └── test/           # Contract test files
├── nix/                 # Nix configuration files
│   ├── package.nix     # Build and deployment configuration
│   └── nixos-module.nix# NixOS service module
└── flake.nix           # Nix flake configuration
```

## Components

- **Hardhat**: Ethereum development environment
- **Chainlink**: Decentralized oracle network
- **Docker**: Container runtime for local testnet
- **Nix**: Reproducible build and deployment system
- **Executor**: Python-based job execution service
- **RPC Failover**: Redundancy service for RPC endpoints
- **Quantra gRPC**: ML model inference service

## Local Development

1. Ensure you have Nix installed with flakes enabled
2. Clone the repository
3. Build required services: `make build`
4. Run `nix run .#reset-testnet` to initialize the environment
5. Use `nix run` or `make run` to start the application

## Testing

After setting up the testnet, you can run the example ping test:
```bash
EXAMPLE_CONTRACT=0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9 npx hardhat run scripts/ping.ts --network localhost
```

## Server Deployment

For bare metal server deployment:
```bash
# Install the package
nix-env -i -f .

# Start the service
systemctl start xnode-blockchain-hpc
```

## Environment Variables

- `EXAMPLE_CONTRACT`: Contract address for testing
- `HOSTNAME`: Server hostname (default: 0.0.0.0)
- `PORT`: Server port (default: 3000)

## License

See LICENSE file.