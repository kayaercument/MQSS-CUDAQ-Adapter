# ============================================================================ #
# Copyright (c) 2022 - 2024 NVIDIA Corporation & Affiliates.                   #
# All rights reserved.                                                         #
# # This source code and the accompanying materials are made available under #
# the terms of the Apache License 2.0 which accompanies this distribution. #
# ============================================================================ #
find_package(GTest REQUIRED)
find_package(crow REQUIRED)

include_directories(${GTEST_INCLUDE_DIRS})
include_directories("${crow_SOURCE_DIR}/include/")

add_executable(test-mqp-mqss MQSS-MQP-Tester.cpp)
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND NOT APPLE)
  target_link_options(test-mqp-mqss PRIVATE -Wl,--no-as-needed)
endif()
target_compile_definitions(test-mqp-mqss PRIVATE -DNVQIR_BACKEND_NAME=mqssMQP)
target_include_directories(test-mqp-mqss PRIVATE ..)
target_link_libraries(
  test-mqp-mqss
  PRIVATE fmt::fmt-header-only
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-common.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-builder.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-mlir-runtime.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-rest-qpu.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-operator.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libnvqir.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libnvqir-qpp.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-platform-default.so
          mqss-cudaq-mqp-adapter
          ${GTEST_LIBRARIES})

# set(CMAKE_CXX_STANDARD 17)
#
# Add Crow headers include_directories(${CMAKE_SOURCE_DIR}/tpls/Crow/include)
#
add_executable(CrowRestServer crow-REST-server.cpp)

target_link_libraries(
  CrowRestServer
  PRIVATE MLIRTransforms
          MLIRPass
          MLIRExecutionEngineUtils
          MLIRSupport
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-common.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-builder.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-mlir-runtime.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-rest-qpu.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-operator.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-platform-default.so
          uuid)

configure_file(
  "MQSS-MQP-StartServerAndTest.sh.in"
  "${CMAKE_BINARY_DIR}/tests/MQP/MQSS-MQP-StartServerAndTest.sh" @ONLY)
configure_file(
  "SimulateKernelLoweredToLLVM.py.in"
  "${CMAKE_BINARY_DIR}/tests/MQP/SimulateKernelLoweredToLLVM.py" @ONLY)

add_test(
  NAME mqp-mqss-cpp-tests
  COMMAND bash MQSS-MQP-StartServerAndTest.sh
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/tests/MQP/)
