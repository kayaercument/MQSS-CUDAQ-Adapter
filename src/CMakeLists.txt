set(LIBRARY_NAME mqss-adapter)

add_library(${LIBRARY_NAME}
  SHARED MQSSQPU.cpp)

target_include_directories(${LIBRARY_NAME} 
    PUBLIC 
       $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
       $<INSTALL_INTERFACE:include> ${CUDAQ_INCLUDE_DIR})


target_link_libraries(${LIBRARY_NAME}
  PUBLIC
  cudaq::cudaq-operator
  cudaq::cudaq-common
  PRIVATE
  cudaq::cudaq-logger
  fmt::fmt-header-only
  cudaq::cudaq
  mqss_client
)

install(
    TARGETS mqss-adapter
    LIBRARY DESTINATION ${CUDAQ_LIBRARY_DIR}
)

install(
    FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/mqss.yml
    DESTINATION
        ${CUDAQ_INSTALL_DIR}/targets
)

set_target_properties(mqss-adapter PROPERTIES
    BUILD_RPATH "/usr/local/lib"
    INSTALL_RPATH "/usr/local/lib"
    POSITION_INDEPENDENT_CODE ON
)