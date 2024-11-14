#!/bin/bash
set -e

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Building from directory: $SCRIPT_DIR"

# Create and use a new builder that supports multi-architecture builds
docker buildx create --name multiarch-builder --use || true

# Build for multiple architectures
echo "Building multi-architecture images..."
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  --tag quantragrpc:latest \
  --file Dockerfile.multiarch \
  --push \
  .

# Build and load the image for the current architecture
echo "Building image for current architecture..."
docker buildx build \
  --platform linux/$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/') \
  --tag quantragrpc:latest \
  --file Dockerfile.multiarch \
  --load \
  .

echo "Build complete!"