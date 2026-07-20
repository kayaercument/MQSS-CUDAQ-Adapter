#include "MQSSQPU.h"

#include "common/ExecutionContext.h"
#include "common/KernelExecution.h"
#include "cudaq/runtime/logger/logger.h"
#include "cudaq_internal/compiler/Compiler.h"

#include <common/CompiledModule.h>
#include <cudaq/platform/qpu_utils.h>
#include <fstream>

namespace cudaq {

sample_result MQSSQPU::launchKernel(const sample_policy &policy,
                                    const AnyModule &module, KernelArgs args) {
  const auto &src = std::get<SourceModule>(module);
  auto rawFn = src.getFunctionPtr();
  KernelThunkType kernelFunc = rawFn ? rawFn->getFn() : nullptr;
  auto packed = args.getPacked();
  void *argData = packed ? packed->data.data() : nullptr;

  auto target = getCompileTarget(policy);
  cudaq_internal::compiler::Compiler compiler(std::move(target));

  auto [moduleOp, context] =
      cudaq_internal::compiler::Compiler::loadQuakeCodeByName(src.getName());

  auto compiled = compiler.runPassPipeline(src.getName(), moduleOp, args, true,
                                           std::move(context));
  auto codes = compiler.emitKernelExecutions(compiled);

  std::string codetoexcute = codes[0].code;

  auto ctx = getExecutionContext();

  auto job = mqss::client::CircuitJobRequest(codetoexcute, "qasm", qpuName,
                                             ctx->shots, false, false);

  client.submitJob(job);
  auto jobResult = client.getJobResult(job, true, 600);

  std::vector<std::map<std::string, unsigned int>> resu =
      jobResult->getResults();
  std::map<std::string, unsigned int> res = resu[0];
  CountsDictionary counts = {res.begin(), res.end()};
  std::vector<ExecutionResult> results = {ExecutionResult{counts}};

  return results;
}

cudaq::async_sample_result
cudaq::MQSSQPU::launchKernel(const async_sample_policy &policy,
                             const cudaq::AnyModule &module,
                             cudaq::KernelArgs args) {
  throw std::runtime_error(
      "MQSSQPU does not support launching the async_sample_policy.");
}

cudaq::observe_result
cudaq::MQSSQPU::launchKernel(const cudaq::observe_policy &policy,
                             const cudaq::AnyModule &module,
                             cudaq::KernelArgs args) {
  throw std::runtime_error(
      "MQSSQPU does not support launching the observe_result.");
}

cudaq::async_observe_result
cudaq::MQSSQPU::launchKernel(async_observe_policy &policy,
                             const cudaq::AnyModule &module,
                             cudaq::KernelArgs args) {
  throw std::runtime_error(
      "MQSSQPU does not support launching the observe_result.");
}

std::unique_ptr<CompileTarget>
MQSSQPU::getCompileTarget(const sample_policy &policy) {
  auto target = std::make_unique<MQSSQPUCompiterTarget>(targetConfig,
                                                        backendConfig, emulate);
  target->supportConditionalsOnMeasureResults = !emulate;
  target->pipelineConfig.addMeasurements = true;
  target->storeReorderIdx = true;
  target->pipelineConfig.replaceStateWithKernel = true;

  return target;
}

void MQSSQPU::setTargetBackend(const std::string &backend) {
  CUDAQ_INFO("MQSSQPU platform is targeting {}.", backend);

  // First we see if the given backend has extra config params
  auto mutableBackend = backend;
  if (mutableBackend.find(";") != std::string::npos) {
    auto split = cudaq::split(mutableBackend, ';');
    mutableBackend = split[0];
    // Must be key-value pairs, therefore an even number of values here
    if ((split.size() - 1) % 2 != 0)
      throw std::runtime_error(
          "Backend config must be provided as key-value pairs: " +
          std::to_string(split.size()));

    // Add to the backend configuration map
    for (std::size_t i = 1; i < split.size(); i += 2) {
      // No need to decode trivial true/false values
      if (split[i + 1].starts_with("base64_")) {
        split[i + 1].erase(0, 7); // erase "base64_"
        std::string decodedStr = detail::decodeBase64(split[i + 1]);
        CUDAQ_INFO("Decoded {} parameter from '{}' to '{}'", split[i],
                   split[i + 1], decodedStr);
        backendConfig.insert({split[i], decodedStr});
      } else {
        backendConfig.insert({split[i], split[i + 1]});
      }
    }
  }

  std::string fileName = mutableBackend + std::string(".yml");
  auto configFilePath = platformPath / fileName;
  CUDAQ_INFO("Config file path = {}", configFilePath.string());
  std::ifstream configFile(configFilePath.string());
  std::string configYmlContents((std::istreambuf_iterator<char>(configFile)),
                                std::istreambuf_iterator<char>());
  detail::parseTargetConfigYml(configYmlContents, targetConfig);
  auto token = backendConfig.find("token")->second;
  qpuName = backendConfig.find("qpu")->second;
  auto url_or_queue = backendConfig.find("url_or_queue")->second;
  auto is_hpc = backendConfig.find("is_hpc")->second == "true";
  client = mqss::client::MQSSClient(token, url_or_queue, is_hpc);
}

} // namespace cudaq
