#pragma once

#include "cudaq/utils/cudaq_utils.h"
#include "mqss/client.h"

#include <cudaq/platform/qpu.h>

namespace cudaq {

/// The MQSSQPU models a simulated QPU by specifically
/// targeting the QIS ExecutionManager.
class MQSSQPU : public QPU {
public:
  ~MQSSQPU() = default;

  /// @brief the platform file path
  std::filesystem::path platformPath;

  mqss::client::MQSSClient client;

  MQSSQPU() : QPU() {
    std::filesystem::path cudaqLibPath{cudaq::getCUDAQLibraryPath()};
    platformPath = cudaqLibPath.parent_path().parent_path() / "targets";
  }

  void enqueue(QuantumTask &task) override { execution_queue->enqueue(task); }

  /// @brief The target configuration
  cudaq::config::TargetConfig targetConfig;

  /// @brief Mapping of general key-values for backend configuration.
  std::map<std::string, std::string> backendConfig;

  /// @brief The name of the QPU being targeted
  std::string qpuName;

  bool emulate = false;

  sample_result launchKernel(const sample_policy &policy,
                             const AnyModule &module, KernelArgs args) override;

  cudaq::async_sample_result launchKernel(const async_sample_policy &policy,
                                          const cudaq::AnyModule &module,
                                          cudaq::KernelArgs args) override;

  cudaq::observe_result launchKernel(const cudaq::observe_policy &policy,
                                     const cudaq::AnyModule &module,
                                     cudaq::KernelArgs args) override;

  cudaq::async_observe_result launchKernel(async_observe_policy &policy,
                                           const cudaq::AnyModule &module,
                                           cudaq::KernelArgs args) override;

  KernelThunkResultType unifiedLaunchModule(const AnyModule &module,
                                            KernelArgs args) override {
    throw std::runtime_error("unifiedLaunchModule.");
  }

  std::unique_ptr<CompileTarget>
  getCompileTarget(const sample_policy &policy) override;

  void setTargetBackend(const std::string &backend) override;
};

class MQSSQPUCompiterTarget : public CompileTarget {
public:
  MQSSQPUCompiterTarget(cudaq::config::TargetConfig targetConfig,
                        std::map<std::string, std::string> runtimeConfig,
                        bool emulate = false)
      : CompileTarget(targetConfig, runtimeConfig, emulate) {}
};
CUDAQ_REGISTER_TYPE(QPU, MQSSQPU, mqss)
} // namespace cudaq
