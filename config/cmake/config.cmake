add_definitions(-D__STDC_CONSTANT_MACROS
				-D__STDC_FORMAT_MACROS
				-D__STDC_LIMIT_MACROS
				-DNOMINMAX)
                

if(WIN32)
add_definitions(-D_CRT_SECURE_NO_WARNINGS 
				-DWIN32_LEAN_AND_MEAN 
				-DUNICODE 
				-D_UNICODE 
				/wd4244 
				/wd4267 
				/wd4996 
				/wd4005 
				/wd4703)
endif(WIN32)

if(WIN32)
	set(CMAKE_CXX_FLAGS "-std=c++11 ${CMAKE_CXX_FLAGS}")
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi")
else(WIN32)
	set(CMAKE_CXX_FLAGS "-std=c++11 -g ${CMAKE_CXX_FLAGS}")
	set(CMAKE_C_FLAGS "-std=c99 ${CMAKE_C_FLAGS}")
endif(WIN32)

if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
	set(CMAKE_CXX_FLAGS "-static-libgcc -static-libstdc++ ${CMAKE_CXX_FLAGS}")
endif()

message("processor is ${CMAKE_SYSTEM_PROCESSOR}" )

string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" SYSPROC)
set(X86_ALIASES x86 i386 i686 x86_64 amd64)
list(FIND X86_ALIASES "${SYSPROC}" X86MATCH)
if("${SYSPROC}" STREQUAL "" OR X86MATCH GREATER "-1")
    message(STATUS "Detected x86 target processor")
    set(TARGET_ARCH "x86")
    if("${CMAKE_SIZEOF_VOID_P}" MATCHES 8)
		message(STATUS "Detected x86_64 target processor")
        set(TARGET_ARCH "x86_64")
    endif()
elseif("${SYSPROC}" STREQUAL "armv7-a")
	set(TARGET_ARCH "armv7")
elseif("${SYSPROC}" STREQUAL "aarch64")
	set(TARGET_ARCH "armv8")
else()
	message(FATAL_ERROR "Unsupport target system.")
endif()

if(IOS)
	if("${CMAKE_OSX_ARCHITECTURES}" STREQUAL "armv7")
		set(TARGET_ARCH "armv7")
	elseif("${CMAKE_OSX_ARCHITECTURES}" STREQUAL "arm64")
		set(TARGET_ARCH "armv8")
	elseif("${CMAKE_OSX_ARCHITECTURES}" STREQUAL "x86_64")
		set(TARGET_ARCH "x86_64")
	endif()
endif(IOS)

if(ANDROID)
	add_definitions(-D__UCLIBC__)
	if(NOT (${CMAKE_C_COMPILER_ID} MATCHES "Clang"))
			set(CMAKE_C_FLAGS "-fno-builtin-cos -fno-builtin-sin -fno-builtin-cosf -fno-builtin-sinf ${CMAKE_C_FLAGS}")
	endif()
	
	if("${TARGET_ARCH}" STREQUAL "armv7")
		set(CMAKE_C_FLAGS "-mfloat-abi=softfp -mfpu=neon ${CMAKE_C_FLAGS}")
		set(CMAKE_CXX_FLAGS "-mfloat-abi=softfp -mfpu=neon ${CMAKE_CXX_FLAGS}")
	endif()
	
	if(CMAKE_C_FLAGS)
		string(REPLACE "-fno-rtti" "" FIXED_C_FLAGS ${CMAKE_C_FLAGS})
		string(REPLACE "-fno-exceptions" "" FIXED_C_FLAGS ${FIXED_C_FLAGS})
		if("${TARGET_ARCH}" STREQUAL "armv7")
			string(REPLACE "-mfpu=vfpv3-d16" "" FIXED_C_FLAGS ${FIXED_C_FLAGS})
		endif()
		set(CMAKE_C_FLAGS ${FIXED_C_FLAGS})
	endif()
	
	if(CMAKE_CXX_FLAGS)
		string(REPLACE "-fno-rtti" "" FIXED_CXX_FLAGS ${CMAKE_CXX_FLAGS})
		string(REPLACE "-fno-exceptions" "" FIXED_CXX_FLAGS ${FIXED_CXX_FLAGS})
		if("${TARGET_ARCH}" STREQUAL "armv7")
			string(REPLACE "-mfpu=vfpv3-d16" "" FIXED_CXX_FLAGS ${FIXED_CXX_FLAGS})
		endif()
		set(CMAKE_CXX_FLAGS ${FIXED_CXX_FLAGS})
	endif()
	
endif()

if(APPLE)
    find_library(fw_core_foundation CoreFoundation)
	find_library(fw_avfoundation AVFoundation)
	find_library(fw_core_video CoreVideo)
    find_library(fw_core_audio CoreAudio)
	find_library(fw_core_media CoreMedia)
	find_library(fw_foundation Foundation)
	find_library(fw_core_graphics CoreGraphics)
	find_library(fw_security Security)
	find_library(fw_system_config SystemConfiguration)
	find_library(fw_videotoolbox VideoToolbox)
	find_library(fw_audiotoolbox AudioToolbox)
    find_library(fw_metal Metal)
    find_library(fw_metalkit MetalKit)
	if(IOS)
        find_library(fw_uikit UIKit)
		find_library(fw_cfnetwork CFNetwork)
        find_library(fw_glkit GLKit)
        find_library(fw_opengles OpenGLES)
        find_library(fw_quartzcore QuartzCore)
	else()
		find_library(fw_appkit AppKit)
		find_library(fw_cocoa Cocoa)
		find_library(fw_iokit IOKit)
		find_library(fw_application_services ApplicationServices)
        find_library(fw_opengl OpenGL)
	endif()
    
    if("${TARGET_ARCH}" MATCHES "arm")
        add_definitions(-D__ARM_NEON)
    endif()
    
endif(APPLE)

if("${TARGET_ARCH}" STREQUAL "armv8")
	add_definitions(-DWEBRTC_ARCH_ARM64 -DWEBRTC_HAS_NEON)
endif()

if("${TARGET_ARCH}" STREQUAL "armv7")
  message(STATUS "use armv7-a")
  add_definitions(-DWEBRTC_ARCH_ARM_V7 -DWEBRTC_HAS_NEON)
  add_definitions(-DWEBRTC_USE_BUILTIN_ISAC_FIX=1)
  add_definitions(-DWEBRTC_USE_BUILTIN_ISAC_FLOAT=0)
else()
  add_definitions(-DWEBRTC_USE_BUILTIN_ISAC_FIX=0)
  add_definitions(-DWEBRTC_USE_BUILTIN_ISAC_FLOAT=1)
endif()


if("${CMAKE_C_COMPILER_ID}" STREQUAL "AppleClang")
	message(STATUS "Complie on apple computer use clang.")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wimplicit-fallthrough -Wthread-safety -Winconsistent-missing-override -Wundef")
  endif()

if(MSVC AND (CMAKE_SIZEOF_VOID_P MATCHES "4"))
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /SAFESEH:NO")
endif()
