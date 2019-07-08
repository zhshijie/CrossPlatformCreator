include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src
                    ${CMAKE_SOURCE_DIR}/sdk/src)

file(GLOB OBJC_ADAPTER_SRC "src/*.h*" "src/*.mm")
source_group("src" FILES ${FILE_SRC})

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fobjc-abi-version=2 -fobjc-arc")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fobjc-abi-version=2 -fobjc-arc")

add_library($$projectName$$Objc STATIC ${OBJC_ADAPTER_SRC})

