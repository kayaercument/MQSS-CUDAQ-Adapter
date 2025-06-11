# Interfaces Diagram

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

The diagram illustrates the architecture and execution flow of CUDA-Q, NVIDIA's hybrid
quantum-classical platform, showing how quantum programs written by users are processed and
executed, either locally or on remote backends. At the top, the flow begins with the user's
quantum-classical code written in either C++ or Python, which interfaces with the CUDA-Q API. This
API acts as the central entry point and splits the execution path into two main directions: **local
simulation** and **remote execution**.

<div align="center">
  <img class="Interfaces" alt="Interfaces diagram" src="interfaces_diagram.png" width=100%>
</div>

For local simulation, the path is straightforward—the user's quantum code is executed directly on
the local system using CUDA-Q's built-in simulators. This is primarily for development and testing.
In contrast, remote execution follows a more complex route. One path leads toward **HPC
(High-Performance Computing)** systems. In this path, CUDA-Q communicates with an Executor, which
manages the execution logic and passes jobs through a RabbitMQ client. This client interacts with
the **MQSS HPC Adapter**, which serves as the interface to external HPC resources.

Parallel to this, CUDA-Q supports execution on **remote quantum devices via REST interfaces**. This
implementation as part of CUDA-Q is backed by a modular `ServerHelper` interface that standardizes
how different quantum providers are integrated. Multiple provider-specific helpers (like
`IonQServerHelper`, `IQMServerHelper`, and `QuantinuumServerHelper`) implement this interface,
enabling seamless interaction with each platform.

Additionally, there's a final link from Remote Quantum Services to the **MQSS MQP Adapter**, which
facilitates further integration into the MQSS.

In essence, this diagram shows how CUDA-Q abstracts the complexity of routing quantum
workloads—offering flexible paths to simulators, HPC infrastructures, and actual quantum
hardware—while maintaining a modular, provider-agnostic design through abstract interfaces and
adapters.

## Submission Sequence via MQP

This diagram illustrates the sequence of operations when a CUDA-Q quantum kernel is executed on a
remote backend, using the RemoteRESTQPU interface, which is the same path followed by the **MQSS
MQP** access. Below is a step-by-step description of the flow, across the involved components:

<div align="center">
  <img class="Sequence MQP" alt="Sequence MQP" src="sequence-MQP.png" width=100%>
</div>

### CUDA-Q Remote Job Execution Flow via MQP (REST API) (Step-by-Step)

### 1. User Code Initiates Execution

- The user calls a quantum kernel in their code.

- This triggers the `launchKernel(name, args)` function in the **CUDA-Q Runtime**.

### 2. Kernel Processing Begins

- `RemoteRESTQPU` is invoked by the runtime.

- Internally:

  - `extractQUAKECodeAndContext()` – Extracts the intermediate QUAKE code representation and
    contextual data.

  - `lowerQUAKECode()` – Lowers the QUAKE code into a backend-compatible form.

  - **CUDA-Q compiler passes** are applied based on the target quantum backend (highlighted box in
    yellow).

### 3. Job Creation

- `RemoteRESTQPU` calls `createJob(circuitCodes)` to construct the job.

- This job is sent to the **ServerHelper**, which:

  - Formats the payload (circuit, metadata) into a provider-specific format.

  - Sends the job to the **RestClient** using:

    - `post(url, payload, headers)` – an HTTP POST request.

### 4. Job Submission

- The **RestClient**:

  - Forwards the job to the **MQSS MQP Offloader**.

  - Receives an HTTP response with a **job ID**.

- `RemoteRESTQPU`:

  - Extracts the job ID from the response: `extractJobId(response)`.

### 5. Polling Loop for Completion

- Enters a loop:

  - Constructs the GET path using `constructGetJobPath(jobId)`.

  - Sends a `GET(path, headers)` request to query job status.

- The provider:

  - Responds with a job status message.

- `RemoteRESTQPU` checks if the job is complete:

  - `jobIsDone(response)`

  - If not complete, it **waits for a polling interval** (highlighted in yellow), and repeats.

### 6. Result Retrieval

- Once the job is complete:

  - The result is extracted and processed: `processResults(response)`

  - A CUDA-Q result object is generated: `cudaq::sample_result`.

### 7. Return to User

- Results are passed back:

  - From `RemoteRESTQPU` → `CUDA-Q Runtime` → `User Code`.

For more information about how to extend CUDA-Q remote devices via REST API, please refer to
[Extending CUDA-Q with a new Hardware Backend](https://nvidia.github.io/cuda-quantum/latest/using/extending/backend.html).

## Submission Sequence via HPC

This diagram outlines the **remote quantum kernel execution flow** in a CUDA-Q environment using
CUDA-Q MQSS Adapter using the HPC access. Here's a step-by-step breakdown of the process shown:

<div align="center">
  <img class="Sequence HPC" alt="Sequence HPC" src="sequence-HPC.png" width=100%>
</div>

### CUDA-Q Remote Job Execution Flow via HPC (Rabbit-MQ) (Step-by-Step)

### 1. User Code Initiates Execution

- The user calls a quantum kernel in their code.

- This triggers the `launchKernel(name, args)` function in the **CUDA-Q Runtime**.

### 2. Kernel Processing Begins

- `HPCQPU` is invoked by the runtime.

- Internally:

  - `extractQUAKECodeAndContext()` – Extracts the intermediate QUAKE code representation and
    contextual data.

  - `lowerQUAKECode()` – Lowers the QUAKE code into a backend-compatible form.

  - **CUDA-Q compiler passes** are applied based on the target quantum backend (highlighted box in
    yellow).

### 3. Job Creation

- `HPCQPU` calls `createJob(circuitCodes)` to construct the job.

- This job is sent to the **ServerHelper**, which:

  - Formats the payload (circuit, metadata) into a provider-specific format.

  - Sends the job to the **RabbitMQClient** using:

### 4. Job Submission

- The **RabbitMQClient**:

  - Forwards the job to the **MQSS HPC Offloader**.

  - Receives a response with a **job ID**.

- `HPCQPU`:

  - Extracts the job ID from the response: `extractJobId(response)`.

### 5. Polling Loop for Completion

- Enters a loop:

  - Query job status.

- The provider:

  - Responds with a job status message.

- `HPCQPU` checks if the job is complete:

  - `jobIsDone(response)`

  - If not complete, it **waits for a polling interval** (highlighted in yellow), and repeats.

### 6. Result Retrieval

- Once the job is complete:

  - The result is extracted and processed: `processResults(response)`

  - A CUDA-Q result object is generated: `cudaq::sample_result`.

### 7. Return to User

- Results are passed back:

  - From `HPCQPU` → `CUDA-Q Runtime` → `User Code`.
