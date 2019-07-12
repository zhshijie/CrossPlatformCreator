include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src
                    ${CMAKE_SOURCE_DIR}/sdk/src)

file(GLOB OBJC_ADAPTER_SRC "demo/*.h*" "demo/*.m*")
source_group("src" FILES ${FILE_SRC})

set(DEMO_TARGET $$projectName$$Demo)
set(DependencedSDK $$projectName$$StaticSDK)

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fobjc-abi-version=2 -fobjc-arc")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fobjc-abi-version=2 -fobjc-arc")

add_executable(${DEMO_TARGET} ${OBJC_ADAPTER_SRC})
add_dependencies(${DEMO_TARGET} ${DependencedSDK})
target_link_libraries(${DEMO_TARGET} ${DependencedSDK})

set_target_properties(
    ${DEMO_TARGET}
    PROPERTIES
    MACOSX_BUNDLE YES
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_LIST_DIR}/Info.plist"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
    XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
    XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES)
