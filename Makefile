.PHONY: build run reset build-all build-chainlink build-rpc-failover build-quantragrpc build-executor

# Default target
all: build run

# Build all services
build-all: build-chainlink build-rpc-failover build-quantragrpc build-executor

# Individual service builds
build-chainlink:
	cd hardhat-app/modules/chainlink && ./build.sh

build-rpc-failover:
	cd hardhat-app/modules/rpc-failover && ./build.sh

build-quantragrpc:
	cd hardhat-app/modules/quantragrpc && ./build.sh

build-executor:
	cd hardhat-app/modules/executor && make build

# Main commands
build: build-all

run:
	nix run

reset:
	nix run .#reset-testnet

# Development helpers
test:
	nix run .#hardhat-test

lint:
	nix run .#hardhat-lint