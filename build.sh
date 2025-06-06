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
QRM_DIR="${DEPS_DIR}/QRM"

# Create directories if they don't exist
mkdir -p "${BUILD_DIR}"

# Navigate to the CUDA Quantum directory
cd "${CUDAQ_DIR}" || { echo "Failed to navigate to ${CUDAQ_DIR}."; exit 1; }

# Create a build directory
mkdir -p build && cd build || { echo "Failed to create or navigate to build directory.";
exit 1; }
mkdir -p build  || { echo "Failed to create build directory."; exit 1; }

# here I have to update those files that I have to build the MQSS target backends
#bash scripts/build_cudaq.sh -j"${NUM_JOBS}"

# Configure CUDA Quantum using CMake
echo "Configuring CUDA Quantum with CMake..."
cmake -G Ninja \
  -DMLIR_DIR="${MLIR_DIR}" \
  -DClang_DIR="${CLANG_DIR}" \
  -DLLVM_DIR="${LLVM_DIR}" \
  ..

if [ $? -ne 0 ]; then
  echo "Cuda quantum with MQSS interfaces failed to build."
  exit 1
fi

# Build the cudaq-mlir-runtime target using Ninja
echo "Building cudaq-mlir-runtime target with ${NUM_JOBS} jobs..."
ninja -j"${NUM_JOBS}" cudaq-common cudaq cudaq-builder cudaq-mlir-runtime cudaq-rest-qpu nvqir nvqir-qpp cudaq-platform-default cudaq-operator

if [ $? -ne 0 ]; then
  echo "Failed to build cudaq-mlir-runtime target."
  exit 1
fi

echo "Build cudaq libraries completed successfully!"

echo ${BUILD_DIR}
cd  "${BUILD_DIR}" || { echo "Failed to navigate back to the original directory."; exit 1; }

echo "Configuring the MQSS CudaQ Adapter repository CMake..."
cmake .. \
  -DCMAKE_C_COMPILER=gcc \
  -DCMAKE_CXX_COMPILER=g++ \
  -DBUILD_CUDAQ_ADAPTER_DOCS="${BUILD_DOCS}"\
  -DCMAKE_INSTALL_PREFIX=${INSTALL_PATH}\
  -DMLIR_DIR="${MLIR_DIR}" \
  -DClang_DIR="${CLANG_DIR}" \
  -DLLVM_DIR="${LLVM_DIR}" \
  -DBUILD_CUDAQ_ADAPTER_TESTS="${BUILD_TESTS}"\
  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
  -DQRM_SOURCE_DIR="${QRM_DIR}"  \
  -DCUDAQ_SOURCE_DIR="${CUDAQ_DIR}"

if [ $? -ne 0 ]; then
  echo "CMake configuration failed."
  exit 1
fi

echo "Building the MQSS CudaQ Adapter with ${NUM_JOBS} jobs..."
make -j"${NUM_JOBS}"
#make install
echo "Build of the MQSS CudaQ Adapter completed successfully!..."
