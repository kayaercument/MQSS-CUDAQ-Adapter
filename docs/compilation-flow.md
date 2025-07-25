# Compilation Flow

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

CUDA-Q (formerly **nvq++**) provides a programming model that integrates quantum kernels with
classical C++ or Python code, enabling hybrid applications. Its compilation flow is built around
LLVM, MLIR, and QIR (Quantum Intermediate Representation).

<div align="center">
  <img class="Compilation" alt="Compilation flow" src="compilation-flow.png" width=100%>
</div>

### 1. Source Code

You write code using CUDA-Q's syntax:

- **C++ with quantum kernels**, e.g.:

```cpp
__qpu__ void bell() {
    qubit q0, q1;
    h(q0);
    cx(q0, q1);
}
```

- **Python front end** is also supported but wraps around C++/LLVM.

### 2. Front-End Parsing & AST Generation

- **C++ source** is parsed using **Clang**, extended with CUDA-Q attributes (**qpu**, etc.).

- The compiler identifies quantum kernels and separates them from classical code.

### 3. MLIR Transformation

- Quantum kernels are lowered into **MLIR (Multi-Level Intermediate Representation).**

- Classical code remains in LLVM IR or C++.

- CUDA-Q uses its own dialects within MLIR (e.g., quake, cc, etc.).

### 4. Quantum IR Generation (QIR)

- The MLIR representation is converted to **QIR** — a standard LLVM-based intermediate
  representation for quantum programs.

- QIR enables **target-agnostic** quantum code that can be interpreted or compiled for multiple
  backends.

### 5. Target-Specific Lowering

- Depending on the selected backend (e.g., **emulator, NVIDIA cuStateVec, IBM Qiskit**, etc.), the
  QIR is further lowered into:

  - **Quantum assembly** (for simulators or real quantum hardware).

  - **CUDA kernels** (if GPU-based simulation is used).

  - **QASM** or vendor-specific IRs.

### 6. Classical Compilation (LLVM)

- The classical host code is compiled using **Clang + LLVM**.

- It links with the runtime libraries that handle quantum kernel dispatching and memory management.

### 7. Linking & Execution

- The final binary includes:

  - Host (classical) code.

  - Quantum kernels embedded as callable functions or LLVM modules.

  - Runtime dependencies (e.g., CUDA-Q runtime, simulators, drivers).

- At runtime, the host code launches quantum kernels on the selected backend, collects results, and
  continues classical processing.

## Compiling using the MQSS CUDA-Q Adapter

- To target MQSS via **MQP** (REST API)

  ```sh
  nvq++ --target mqssMQP your_application_source.cpp -o your_binary_application
  ```

- To target MQSS via **HPC** (coming soon, not supported yet by the MQSS v1)

  ```sh
  nvq++ --target mqssHPC your_application_source.cpp -o your_binary_application
  ```

## Executing your Application with Configuration File and Credentials

Once the binary of your application was successfully generated. You can execute your application to
submit quantum circuits to the MQSS, as follows:

```sh
MQSS_MQP_TOKEN=your/token/file/path CUDAQ_MQSS_CONFIGURATION=/your/configuration/file/path ./your_binary_application
```

The environment variable `MQSS_MQP_TOKEN` is used to specify the path of a text file containing a
token to access to the MQP. To generate a valid token please go to the
[Munich Quantum Portal (MQP)](https://portal.quantum.lrz.de/).

A configuration file is a requirement to send additional information to be used at runtime by the
MQSS.

The environment variable `CUDAQ_MQSS_CONFIGURATION` has to be defined in order to include the
configuration file during runtime.

The configuration file might contain the following information:

- `n_shots` is the number of shots required to execute the quantum task. This is annotated by MQSS
  CUDA-Q Adapter and it is not required to be defined in the configuration file.
- `transpiler_flag` is a flag indicating if the MQSS has to perform transpilation. `true` indicates
  the flag is active, `false` otherwise.
- `submit_time` is the submission time of the task. This is annotated by MQSS CUDA-Q Adapter on each
  submitted task and it is not required to be defined in the configuration file.
- `circuit_file_type` is the circuit type submitted to the MQSS. The supported file types at the
  moment are: QASMi, Quake, and QIR.
- `preferred_qpu` specifies the selected preferred QPU where the submitted jobs will be executed.
- `restricted_resource_names` specifies the restricted QPUs when submitting a job the MQSS.
- `priority` integer value that specified the priority level of the submitted.
- `user_identity` specifies the identity of the user.
- `optimisation_level` specifies the optimization level. Supported levels: 0, 1, 2, and 3.
- `via_hpc` is a flag specifying if the job is submitted via HPC or MQP. `true` indicates the job is
  submitted via HPC, `false` via MQP. This is annotated by MQSS CUDA-Q Adapter on each submitted
  task and it is not required to be defined in the configuration file.

In the following an example of a configuration file:

```sh
n_shots: 1000
transpiler_flag: true
circuit_file_type: qasm
preferred_qpu: QExa20
restricted_resource_names: AQT20
priority: 1
user_identity: YOUR IDENTITY
optimisation_level: 3
```
