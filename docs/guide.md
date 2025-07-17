# Installation Guide

<!-- IMPORTANT: Keep the line above as the first line. -->

<!----------------------------------------------------------------------------
Copyright 2024 Munich Quantum Software Stack Project

Licensed under the Apache License, Version 2.0 with LLVM Exceptions (the
"License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at

https://github.com/Munich-Quantum-Software-Stack/MQSS-CUDAQ-Adapter/blob/develop/LICENSE

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License.

SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
-------------------------------------------------------------------------- -->

<!-- This file is a static page and included in the CMakeLists.txt file. -->

Ready to use the MQSS CUDA-Q Adapter? This guide will help you get started.

## Installing CUDA-Q

Since the MQSS CUDA-Q Adapter is a plugin of the NVIDIA CUDA-Quantum (CUDA-Q) programming interface,
your system must contain an installation of CUDA-Q as a main prerequisite.

We recommend to follow the instructions of installation described in the following link:
[CUDA-Q Documentation](https://nvidia.github.io/cuda-quantum/latest/using/quick_start.html#install-cuda-q)

## Initial Setup

1. Clone the MQSS CUDA-Q Adapter:

   ```sh
   git clone https://github.com/Munich-Quantum-Software-Stack/MQSS-CUDAQ-Adapter
   ```

2. Change into the project directory:

   ```sh
   cd MQSS-CUDAQ-Adapter
   ```

3. Run the following command to update the sub-modules of the project:

   ```sh
   git submodule update --init --recursive
   ```

4. Run the following script to configure this project and set up the MQSS CUDA-Q Adapter:

   ```sh
   bash generate_and_apply_patch.sh
   ```

## Alternative: Visual Studio Code DevContainer (Strongly recommended)

**Dev Containers** (short for Development Containers) are an environment configuration that allows
developers to create a consistent, isolated environment for development, testing, and deployment.
They are typically used in conjunction with Visual Studio Code (**VS Code**) and **Docker** to
ensure that the development environment is the same across all team members, regardless of their
host machine or operating system.

- Open the repository in VS-code
- Use the Dev Container plugin to Open Folder in Container. This should pull and install CUDA-Q and
  the required dependencies.

The previous steps creates an isolated environment where you can tests this project. The project is
located:

```shell
cd /workspaces/MQSS-CUDAQ-Adapter
```

### Build and install

Building the project requires a C++ compiler supporting _C11_ and a minimum CMake version of _3.19_.
The example devices and the tests require a C++ compiler supporting _C++17_ and _C++20_ dialects.

The script `generate_and_apply_patch.sh` clone the source code of CUDA-Q and fetch also the MQSS
CUDA-Q Adapter. You need to rebuild the entire CUDA-Q and install. After this the CUDA-Q compiler
will show `mqMQP` when running `nvq++ --list-targets`.

```shell
bash build.sh --jobs 5
```

In the following, we describe each of the arguments accepted by `build.sh`.

- `--jobs` (**optional**) The number of jobs utilized to configure and compile this project. If not
  specified, a single job is used to compile the project.

- `--mlir-dir` Path of your MLIR installation. E.g., `/opt/llvm/lib/cmake/mlir/`
- `--clang-dir` Path of your Clang installation.
- `--llvm-dir` Path of your LLVM installation.

After the installation you can verify if the installation was successful, by running the following
script:

```shell
nvq++ --list-targets
  ...
  mqssMQP
  ...
```

You can see listed the targets `mqssMQP` corresponding to the MQP access to the MQSS.

### Format for Comments

For the information to be displayed correctly in the documentation, it is essential that the
comments follow the format required by Doxygen. Below you find some tags, that are commonly used
within the documentation of a function:

- `@brief` For a brief, one-line description of the function. Should always be provided.
- `@details` For a longer, detailed description of the function.
- `@param` To explain the usage of a parameter. Should be provided for each parameter.
- `@return` To explain the return value. Should be provided if the function returns a value.

\note In the current setting, the long description is always prepended with the brief description.
So there is no need to repeat the brief description in the details.

## Working on the Documentation

The documentation is generated using [Doxygen](https://www.doxygen.nl/index.html), which is
seamlessly integrated into the CMake build system.

### Building the Documentation

The documentation can be built using the `build_doc.sh` script.

```shell
bash build_doc.sh --build-docs
```

The generated webpage can be inspected by opening the file in `docs/html/index.html` in the CMake
build directory.

### Static Content

The generated webpage also contains four static sites, namely the main page, the support page, the
FAQ page, and this development guide. The respective markdown files that serve as the source for
those sites are contained in `docs/` where `index.md` contains the content of the main page.

### Dynamic Content

In order to include source files to be listed among the menu item `API Reference/Files`, these files
must be marked as documented. This is accomplished by adding a comment like the following to the top
of the file. Right now, this is done for all files in the include directory.

### Further Links

- For more details, see the official documentation of Doxygen that can be found here:
  [https://www.doxygen.nl/manual/docblocks.html](https://www.doxygen.nl/manual/docblocks.html).
- More tags and commands can be found in the list provided here:
  [https://www.doxygen.nl/manual/commands.html#cmd_intro](https://www.doxygen.nl/manual/commands.html#cmd_intro)
