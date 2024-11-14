#!/bin/bash
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Building from directory: $SCRIPT_DIR"

# Detect current architecture
CURRENT_ARCH=$(uname -m)
case $CURRENT_ARCH in
    "x86_64")  TARGET_PLATFORM="linux/amd64" ;;
    "arm64")   TARGET_PLATFORM="linux/arm64" ;;
    "aarch64") TARGET_PLATFORM="linux/arm64" ;;
    *)         TARGET_PLATFORM="linux/amd64" ;;
esac

echo "Detected architecture: $CURRENT_ARCH"
echo "Building for platform: $TARGET_PLATFORM"

# Build for current architecture
docker buildx build \
  --platform $TARGET_PLATFORM \
  --tag rpc-failover:latest \
  --file Dockerfile.multiarch \
  --load \
  .

echo "Build complete!"