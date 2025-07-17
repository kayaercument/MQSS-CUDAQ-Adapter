#!/bin/bash

# Define directoriesi
CURRENT_DIR=$(pwd)

INSTALL_PATH="${INSTALL_PATH:-$HOME}"
# Default values
NUM_JOBS=1  # Default number of jobs
BUILD_DOCS=OFF  # Default: Do not build documentation
BUILD_TYPE="Release"  # Default: Release mode

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -j|--jobs)
      NUM_JOBS="$2"
      shift 2
      ;;
		--debug)
    	BUILD_TYPE="Debug"
    	shift
    	;;
    --install-dir)
      INSTALL_DIR="$2"
      shift 2
      ;;
    --build-docs)
      BUILD_DOCS=ON
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

BUILD_DIR=${CURRENT_DIR}"/build"
# Create directories if they don't exist
mkdir -p "${BUILD_DIR}"

cd  "${BUILD_DIR}" || { echo "Failed to navigate back to the original directory."; exit 1; }

echo "Configuring the MQSS CudaQ Adapter repository CMake..."
cmake .. \
  -DCMAKE_C_COMPILER=gcc \
  -DCMAKE_CXX_COMPILER=g++ \
  -DBUILD_CUDAQ_ADAPTER_DOCS="${BUILD_DOCS}"\
  -DCMAKE_INSTALL_PREFIX=${INSTALL_PATH}\
  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}"

if [ $? -ne 0 ]; then
  echo "CMake configuration failed."
  exit 1
fi

echo "Building the MQSS CudaQ Adapter documentation with ${NUM_JOBS} jobs..."
make -j"${NUM_JOBS}"

echo "Build of the MQSS CudaQ Adapter documentation completed successfully!..."
