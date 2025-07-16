#!/bin/bash

# Define directoriesi
CURRENT_DIR=$(pwd)

INSTALL_PATH="${INSTALL_PATH:-$HOME}"
# Default values
NUM_JOBS=1  # Default number of jobs
BUILD_DOCS=OFF  # Default: Do not build documentation
BUILD_TESTS=OFF  # Default: Do not build tests
BUILD_TYPE="Release"  # Default: Release mode

# Default directories (can be overridden by arguments)
MLIR_DIR="/opt/llvm/lib/cmake/mlir"
CLANG_DIR="/opt/llvm/lib/cmake/clang"
LLVM_DIR="/opt/llvm/lib/cmake/llvm"
CUDAQ_BUILD_TESTS=FALSE
export CUDAQ_BUILD_TESTS
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
    --mlir-dir)
      MLIR_DIR="$2"
      shift 2
      ;;
    --install-dir)
      INSTALL_DIR="$2"
      shift 2
      ;;
    --clang-dir)
      CLANG_DIR="$2"
      shift 2
      ;;
    --llvm-dir)
      LLVM_DIR="$2"
      shift 2
      ;;
    --build-tools)
      BUILD_TOOLS=ON
      shift
      ;;
    --build-docs)
      BUILD_DOCS=ON
      shift
      ;;
    --build-tests)
      BUILD_TESTS=ON
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

BUILD_DIR=${CURRENT_DIR}"/build"
DEPS_DIR="${CURRENT_DIR}/extern"
CUDAQ_DIR="${DEPS_DIR}/cuda-quantum"

# Create directories if they don't exist
mkdir -p "${BUILD_DIR}"

# Navigate to the CUDA Quantum directory
cd "${CUDAQ_DIR}" || { echo "Failed to navigate to ${CUDAQ_DIR}."; exit 1; }

# here I have to update those files that I have to build the MQSS target backends
echo "Installing CUDA-Q with MQSS CUDA-Q Adapter..."
bash scripts/build_cudaq.sh -j"${NUM_JOBS}"
if [ $? -ne 0 ]; then
  echo "Failed to install MQSS CUDA-Q Adapter"
  exit 1
fi

echo "Build of the MQSS CudaQ Adapter completed successfully!..."
