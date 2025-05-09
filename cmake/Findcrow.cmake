include(FetchContent)

FetchContent_Declare(
  crow
  GIT_REPOSITORY https://github.com/CrowCpp/crow.git
  GIT_TAG v1.0+2 # or use the latest stable tag
)

FetchContent_MakeAvailable(crow)
