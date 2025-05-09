cmake_minimum_required(VERSION 3.22.1)
project(
  QuantumResourceManager
  VERSION 0.1
  DESCRIPTION "Quantum Resource Manager"
  LANGUAGES C CXX)

# Set the C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED on)
set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)
set(CMAKE_CXX_FLAGS "-w -fPIC")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-switch")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -frtti -fexceptions")

# Tell where to find fetch content, etc.
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

find_package(MLIR REQUIRED CONFIG)
message(STATUS "Using MLIRConfig.cmake in: ${MLIR_DIR}")

list(APPEND CMAKE_MODULE_PATH "${MLIR_CMAKE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules")

include(TableGen)
include(AddLLVM)
include(AddMLIR)

# Add LLVM, Clang and MLIR headers to the include path
include_directories(SYSTEM ${LLVM_INCLUDE_DIRS} ${CLANG_INCLUDE_DIRS}
                    ${MLIR_INCLUDE_DIRS})
# ##############################################################################
# Find FOMAC package find_package(fomac REQUIRED) Find QDMI package
find_package(qdmi REQUIRED)
# Find QInfo package find_package(qinfo REQUIRED) Find nlohmann_json package
find_package(fmt REQUIRED)
find_package(nlohmann_json REQUIRED)
# Find the Threads package
find_package(Threads REQUIRED)
find_package(rabbitmq-c REQUIRED)
find_package(MLIRPasses REQUIRED)

set(Boost_USE_STATIC_LIBS ON)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
find_package(Boost REQUIRED)
message(STATUS "Boost version: ${Boost_VERSION}")
if(NOT Boost_FOUND)
  message(FATAL_ERROR "Boost library not found.")
endif()
find_package(BoostUUID REQUIRED)

# configure the MLIR Passes repo
set(PASSES_SOURCE_DIR ${MLIRPasses_SOURCE_DIR})
set(PASSES_INCLUDE_DIR "${PASSES_SOURCE_DIR}/include")
set(PASSES_TB_INCLUDE_DIR "${MLIRPasses_BINARY_DIR}/include")
include_directories(${PASSES_INCLUDE_DIR})
include_directories(${PASSES_TB_INCLUDE_DIR})

set(MQT_QMAP_INCLUDE_DIR "${mqt-qmap_SOURCE_DIR}/include/")
set(MQT_QCEC_INCLUDE_DIR "${mqt-qcec_SOURCE_DIR}/include/")
set(MQT_CORE_INCLUDE_DIR "${mqt-core_SOURCE_DIR}/include/mqt-core")

# Add the include paths
include_directories(
  BEFORE
  ${LLVM_INCLUDE_DIRS}
  ${MLIR_INCLUDE_DIRS}
  ${MQT_QMAP_INCLUDE_DIR}
  ${MQT_CORE_INCLUDE_DIR}
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/include/mqss"
  "${CMAKE_CURRENT_SOURCE_DIR}/include/mqss/Utils"
  "${CMAKE_CURRENT_SOURCE_DIR}/include/mqss/QuantumResourceManager"
  "${CMAKE_CURRENT_SOURCE_DIR}/include/mqss/QuantumResourceManager/PassManager")

# ###################### CUDAQ settings ###################################
set(CUDAQ_MAIN_INCLUDE_DIR "${CUDAQ_SOURCE_DIR}/include")

set(CUDAQ_BINARY_DIR "${CUDAQ_SOURCE_DIR}/build")
set(CUDAQ_CMAKE_DIR "${CUDAQ_SOURCE_DIR}/cmake")
set(CUDAQ_INCLUDE_DIR "${CUDAQ_SOURCE_DIR}/build/include")
set(CUDAQ_LIBRARY_DIR "${CUDAQ_SOURCE_DIR}/build/lib")
set(CUDAQ_TOOLS_DIR "${CUDAQ_SOURCE_DIR}/build/bin")
set(CUDAQ_MLIR_RUNTIME_PATH "${CUDAQ_BINARY_DIR}/lib")
message(STATUS "CUDAQ bin ${CUDAQ_MLIR_RUNTIME_PATH}")

include_directories(BEFORE ${CUDAQ_MAIN_INCLUDE_DIR}
                    ${CUDAQ_BINARY_DIR}/include ${CUDAQ_SOURCE_DIR}/runtime)

# Validate CUDAQ dependencies
if(NOT EXISTS ${CUDAQ_BINARY_DIR}/lib/libcudaq-mlir-runtime.so)
  message(
    FATAL_ERROR
      "Invalid CUDAQ dir: ${CUDAQ_SOURCE_DIR}. Cannot find libcudaq.so in build directory."
  )
endif()
set(CUDAQ_TARGETS ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-mlir-runtime.so)
# ##############################################################################
