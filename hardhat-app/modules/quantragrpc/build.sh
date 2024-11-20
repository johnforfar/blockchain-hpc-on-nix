#!/bin/bash
set -eo pipefail

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

echo "Building quantragrpc for $TARGET_PLATFORM..."
echo "Step 1/4: Cleaning Docker cache..."
docker builder prune -f --filter type=exec.cachemount >/dev/null 2>&1

echo "Step 2/4: Preparing build environment..."
# Create a timestamp for build tracking
timestamp=$(date +%s)
echo "Build started at: $(date)"

echo "Step 3/4: Building image..."
# Build with progress tracking
docker buildx build \
    --platform $TARGET_PLATFORM \
    --tag quantragrpc:latest \
    --file Dockerfile.multiarch \
    --load \
    --network=host \
    --build-arg BUILDPLATFORM=$TARGET_PLATFORM \
    --build-arg TARGETPLATFORM=$TARGET_PLATFORM \
    --progress=plain \
    . 2>&1 | tee /tmp/build_${timestamp}.log | grep -E '^#[0-9]+\s+(ERROR|DONE|\[builder|\[stage).*$|^ERROR:.*$|error:.*$' | grep -v "DONE 0.0s" | grep -v "CACHED"

# Check build status
exit_code=${PIPESTATUS[0]}

echo "Step 4/4: Finalizing build..."
if [ $exit_code -ne 0 ]; then
    echo "❌ Build failed after $(($(date +%s) - timestamp)) seconds"
    echo "Last 10 lines of build log:"
    tail -n 10 /tmp/build_${timestamp}.log
    rm /tmp/build_${timestamp}.log
    exit $exit_code
fi

echo "✅ Build completed successfully in $(($(date +%s) - timestamp)) seconds"
rm /tmp/build_${timestamp}.log

# Display image details if build successful
if [ $exit_code -eq 0 ]; then
    echo "Image details:"
    docker images quantragrpc:latest
fi