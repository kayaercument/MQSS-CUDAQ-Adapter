include(FetchContent)

SET(BUILD_SHARED_LIBS OFF)

FetchContent_Declare(
  mqss-client
  GIT_REPOSITORY https://github.com/kayaercument/MQSS-Client.git
  GIT_TAG develop
  )
  
FetchContent_MakeAvailable(mqss-client)
