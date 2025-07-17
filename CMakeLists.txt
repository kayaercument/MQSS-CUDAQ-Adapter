# This code and any associated documentation is provided "as is"
#
# Copyright 2025 Munich Quantum Software Stack Project
#
# Licensed under the Apache License, Version 2.0 with LLVM Exceptions (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# TODO
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
  VERSION 0.1
  DESCRIPTION "Documentation of the CUDA-Q Adapter"
  LANGUAGES C CXX)

# Set the C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED on)
set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)
set(CMAKE_CXX_FLAGS "-w -fPIC")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-switch")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -frtti -fexceptions")

# Set default build type to Debug if none is specified
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE
      Debug
      CACHE STRING "Build type (Debug, Release)" FORCE)
endif()

# Define macros for Debug builds
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  message("Configuring for Debug mode")
  add_compile_definitions(DEBUG)
endif()

# Tell where to find fetch content, etc.
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})
include(cmake/ExternalDependencies.cmake)

# add documentation
if(BUILD_CUDAQ_ADAPTER_DOCS)
  add_subdirectory(docs)
endif()
