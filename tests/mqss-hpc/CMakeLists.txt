# This code and any associated documentation is provided "as is"
#
# Copyright 2025 Munich Quantum Software Stack Project
#
# Licensed under the Apache License, Version 2.0 with LLVM Exceptions (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://github.com/Munich-Quantum-Software-Stack/MQSS-CUDAQ-Adapter/blob/develop/LICENSE
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
# *****************************************************************************
# * This source code and the accompanying materials are made available under
# * the terms of the Apache License 2.0 which accompanies this distribution.
# *****************************************************************************

find_package(GTest REQUIRED)

add_executable(test-hpc-mqss MQSS-HPC-Tester.cpp)
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND NOT APPLE)
  target_link_options(test-hpc-mqss PRIVATE -Wl,--no-as-needed)
endif()
target_compile_definitions(test-hpc-mqss PRIVATE -DNVQIR_BACKEND_NAME=mqssHPC)
target_include_directories(test-hpc-mqss PRIVATE ../..)
target_link_libraries(
  test-hpc-mqss
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
          ${GTEST_LIBRARIES})

# Add RabbitMQ
find_package(PkgConfig REQUIRED)
pkg_check_modules(RABBITMQ REQUIRED librabbitmq)
include_directories(${RABBITMQ_INCLUDE_DIRS})
add_executable(RabbitMQ-Consumer RabbitMQ-Consumer.cpp RabbitMQServer.cpp)
# Link with uuid library
target_link_libraries(
  RabbitMQ-Consumer
  PRIVATE MLIRTransforms
          MLIRPass
          MLIRExecutionEngineUtils
          MLIRSupport
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-common.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-builder.so
          ${CUDAQ_MLIR_RUNTIME_PATH}/libcudaq-mlir-runtime.so
          ${RABBITMQ_LIBRARIES}
          # cudaq-platform-default
          uuid)

configure_file(
  "MQSS-HPC-StartServerAndTest.sh.in"
  "${CMAKE_BINARY_DIR}/tests/mqss-hpc/MQSS-HPC-StartServerAndTest.sh" @ONLY)
configure_file(
  "SimulateKernelLoweredToLLVM.py.in"
  "${CMAKE_BINARY_DIR}/tests/mqss-hpc/SimulateKernelLoweredToLLVM.py" @ONLY)

add_test(
  NAME hpc-mqss-tests
  COMMAND bash MQSS-HPC-StartServerAndTest.sh
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/tests/mqss-hpc/)
