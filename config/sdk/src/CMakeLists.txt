cmake_minimum_required(VERSION 3.8)

project($$projectName$$)
set(LIBNAME "$$libnameName$$")
set(STATIC_LIBNAME "$$projectName$$StaticSDK")

# cpp header file
file(GLOB sdk_public_header "header/*.h*")
source_group("header" FILES ${sdk_public_header})


# cocoa header file
file(GLOB objc_public_header "${CMAKE_SOURCE_DIR}/sdk/cocoa/src/*.h*")
file(GLOB objc_src "${CMAKE_SOURCE_DIR}/sdk/cocoa/src/*.mm")


#source file
file(GLOB sdk_src "src/*.h*" "src/*.c*" "src/*.m*")
source_group("src" FILES ${sdk_src})


if(WIN32)
  set(CMAKE_CXX_FLAGS "-std=c++11 ${CMAKE_CXX_FLAGS}")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi")
  set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /DEBUG /OPT:REF /OPT:ICF")
else(WIN32)
  set(CMAKE_CXX_FLAGS "-std=c++11 -g -o0 -static-libgcc -static-libstdc++ ${CMAKE_CXX_FLAGS}")
  if(__linux__)
    set(CMAKE_CXX_FLAGS "-lpthread ${CMAKE_CXX_FLAGS}")
  endif(__linux__)
endif(WIN32)

if(${CMAKE_C_COMPILER_ID} MATCHES "Clang")
  message(STATUS "Complie on apple computer use clang.")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-shorten-64-to-32")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-command-line-argument")
endif()

if(ANDROID)
  string(REPLACE "-fno-rtti" "" FIXED_C_FLAGS ${CMAKE_C_FLAGS})
  string(REPLACE "-fno-exceptions" "" FIXED_C_FLAGS ${FIXED_C_FLAGS})
  if(CMAKE_SYSTEM_PROCESSOR STREQUAL "armv7-a")
    string(REPLACE "-mfpu=vfpv3-d16" "" FIXED_C_FLAGS ${FIXED_C_FLAGS})
  endif()
  set(CMAKE_C_FLAGS ${FIXED_C_FLAGS})


  string(REPLACE "-fno-rtti" "" FIXED_CXX_FLAGS ${CMAKE_CXX_FLAGS})
  string(REPLACE "-fno-exceptions" "" FIXED_CXX_FLAGS ${FIXED_CXX_FLAGS})
  if(CMAKE_SYSTEM_PROCESSOR STREQUAL "armv7-a")
    string(REPLACE "-mfpu=vfpv3-d16" "" FIXED_CXX_FLAGS ${FIXED_CXX_FLAGS})
  endif()
  set(CMAKE_CXX_FLAGS ${FIXED_CXX_FLAGS})

  add_definitions(-DJSONCPP_NO_LOCALE_SUPPORT)
  
endif()


if(APPLE)
  if(IOS)
    set(CMAKE_SYSTEM_PROCESSOR aarch64)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --target=arm64-apple-darwin-eabi-as")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --target=arm64-apple-darwin-eabi-as")
    set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} --target=arm64-apple-darwin-eabi-as")
  else()
    set(CMAKE_SYSTEM_PROCESSOR x86_64)
  endif()
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -D_DEBUG=3")
  set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -D_DEBUG=4")
endif()


if(ANDROID)

  file(GLOB jni_src "jni/*")
  list(APPEND sdk_src ${jni_src})

endif()

if(APPLE)
  list(APPEND sdk_src 
    ${sdk_public_header}
    ${objc_public_header}
    ${objc_src}
    )
endif()

if(APPLE)
    find_library(fr_foundation Foundation)
    list(APPEND apple_system_libs
        ${fr_core_foundation}  
        ${fr_foundation}
  )
endif(APPLE)

# generate shared library
add_library(${LIBNAME} SHARED ${sdk_src})
add_library(${STATIC_LIBNAME}  ${sdk_src})

if(APPLE)
  # 添加 iOS 第三方依赖库链接
  # target_link_libraries(${LIBNAME} 
  #						${apple_system_libs}
  #						CONAN_PKG::boringssl)

  # target_link_libraries(${STATIC_LIBNAME} 
  #						${apple_system_libs}
  #						CONAN_PKG::boringssl)
endif(APPLE)

if(ANDROID)
  # 添加 Android 第三方依赖库链接
  # target_link_libraries(${LIBNAME} atomic
  #						CONAN_PKG::boringssl)
endif()


if(APPLE)	
  set(CMAKE_SKIP_RPATH FALSE)
  set_target_properties(${LIBNAME} PROPERTIES FRAMEWORK true)
  set_target_properties(${LIBNAME} PROPERTIES MACOSX_FRAMEWORK_IDENTIFIER "$$BundleId$$")
  set_target_properties(${LIBNAME} PROPERTIES PUBLIC_HEADER "${objc_public_header}")
  set_target_properties(${LIBNAME} PROPERTIES OUTPUT_NAME "${LIBNAME}")
  
  set_target_properties(${STATIC_LIBNAME} PROPERTIES FRAMEWORK true)
  set_target_properties(${STATIC_LIBNAME} PROPERTIES MACOSX_FRAMEWORK_IDENTIFIER "$$BundleId$$_static")
  set_target_properties(${STATIC_LIBNAME} PROPERTIES PUBLIC_HEADER "${objc_public_header}")
  set_target_properties(${STATIC_LIBNAME} PROPERTIES OUTPUT_NAME "${STATIC_LIBNAME}")
  
endif()
