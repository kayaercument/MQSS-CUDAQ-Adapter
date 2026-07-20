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
# *******************************************************************************
# * This source code and the accompanying materials are made available under
# * the terms of the Apache License 2.0 which accompanies this distribution.
# *******************************************************************************

cmake_minimum_required(VERSION 3.22.1)
project(
  Documentation-CUDA-Q-Adapter
  VERSION 0.2
  DESCRIPTION "Documentation of the CUDA-Q Adapter"
  LANGUAGES C CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS
    ON
    CACHE BOOL "Export compile commands" FORCE)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

set(CUDAQ_LIBRARY_MODE TRUE)
find_package(CUDAQ REQUIRED)
find_package(mqss-client REQUIRED)

add_subdirectory(src)
