find_program(CONAN_EXECUTABLE conan)

if (CONAN_EXECUTABLE)
	message(${CONAN_EXECUTABLE})

	if(NOT CONAN_SETUP)
	    set(CONAN_SETUP TRUE)
        execute_process(COMMAND ${CONAN_EXECUTABLE} --version
                        OUTPUT_VARIABLE conan_version)
                            
        if(APPLE)
            if(IOS)
                set(CONAN_OS "iOS")
            else(IOS)
                set(CONAN_OS "Macos")
            endif(IOS)
        else(APPLE)
            set(CONAN_OS ${CMAKE_SYSTEM_NAME})
        endif(APPLE)

        list(APPEND CONAN_SETTINGS -s os=${CONAN_OS})

        if(IOS)
            list(APPEND CONAN_SETTINGS -s os.version=10.0)
        endif(IOS)

        if(ANDROID)
            list(APPEND CONAN_SETTINGS -s os.api_level=21)
        endif(ANDROID)

        message("processor is ${CMAKE_SYSTEM_PROCESSOR}" )

        string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" SYSPROC)
        set(X86_ALIASES x86 i386 i686 x86_64 amd64)
        list(FIND X86_ALIASES "${SYSPROC}" X86MATCH)
        if("${SYSPROC}" STREQUAL "" OR X86MATCH GREATER "-1")
            message(STATUS "Detected x86 target processor")
            set(CONAN_ARCH "x86")
            if("${CMAKE_SIZEOF_VOID_P}" MATCHES 8)
                message(STATUS "Detected x86_64 target processor")
                set(CONAN_ARCH "x86_64")
            endif()
        elseif("${SYSPROC}" STREQUAL "armv7-a")
            set(CONAN_ARCH "armv7")
        elseif("${SYSPROC}" STREQUAL "aarch64")
            set(CONAN_ARCH "armv8")
        else()
            message(FATAL_ERROR "Unsupport target system.")
        endif()

        if(IOS)
            if("${CMAKE_OSX_ARCHITECTURES}" STREQUAL "armv7")
                set(CONAN_ARCH "armv7")
            elseif("${CMAKE_OSX_ARCHITECTURES}" STREQUAL "arm64")
                set(CONAN_ARCH "armv8")
            elseif("${CMAKE_OSX_ARCHITECTURES}" STREQUAL "x86_64")
                set(CONAN_ARCH "x86_64")
            endif()
        endif(IOS)
                        
        list(APPEND CONAN_SETTINGS -s arch=${CONAN_ARCH})

        if("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU")
            set(CONAN_COMPLIER "gcc")
        elseif(MSVC)
            set(CONAN_COMPLIER "Visual Studio")
        elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "AppleClang")
            set(CONAN_COMPLIER "apple-clang")
        elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang")
            set(CONAN_COMPLIER "clang")
        else()
            message(FATAL_ERROR "Unsupport complier.")
        endif()

        list(APPEND CONAN_SETTINGS -s compiler=${CONAN_COMPLIER} )
        if(MSVC)
            if(${MSVC_VERSION} EQUAL 1600)
                list(APPEND CONAN_SETTINGS -s compiler.version=10)
            elseif(${MSVC_VERSION} EQUAL 1700)
                list(APPEND CONAN_SETTINGS -s compiler.version=11)
            elseif(${MSVC_VERSION} EQUAL 1800)
                list(APPEND CONAN_SETTINGS -s compiler.version=12)
            elseif(${MSVC_VERSION} EQUAL 1900)
                list(APPEND CONAN_SETTINGS -s compiler.version=14)
            elseif(${MSVC_VERSION} GREATER 1900)
                list(APPEND CONAN_SETTINGS -s compiler.version=15)
            endif()
        elseif((${CMAKE_C_COMPILER_VERSION} VERSION_GREATER_EQUAL 5) AND ("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux"))
            message(STATUS "compiler version: ${CMAKE_C_COMPILER_VERSION}")
            string(SUBSTRING ${CMAKE_C_COMPILER_VERSION} 0 1 COMPILER_VERSION)
            list(APPEND CONAN_SETTINGS -s compiler.version=${COMPILER_VERSION})
        else()
            message(STATUS "compiler version: ${CMAKE_C_COMPILER_VERSION}")
            string(SUBSTRING ${CMAKE_C_COMPILER_VERSION} 0 3 COMPILER_VERSION)
            list(APPEND CONAN_SETTINGS -s compiler.version=${COMPILER_VERSION})
        endif()

        if("${CMAKE_C_COMPILER_ID}" STREQUAL "AppleClang")
            if(NOT "${CMAKE_C_COMPILER_VERSION}" LESS  "10")
                message(STATUS "compiler version: ${CMAKE_C_COMPILER_VERSION}")
                string(SUBSTRING ${CMAKE_C_COMPILER_VERSION} 0 4 COMPILER_VERSION)
                list(APPEND CONAN_SETTINGS -s compiler.version=${COMPILER_VERSION})
                list(APPEND CONAN_SETTINGS -s compiler.libcxx=libc++)
            else()
                message(STATUS "compiler version: ${CMAKE_C_COMPILER_VERSION}")
                string(SUBSTRING ${CMAKE_C_COMPILER_VERSION} 0 3 COMPILER_VERSION)
                list(APPEND CONAN_SETTINGS -s compiler.version=${COMPILER_VERSION})
                list(APPEND CONAN_SETTINGS -s compiler.libcxx=libstdc++)
            endif()
        endif()

        message("Use this conan settings:")
        message(${CONAN_SETTINGS})

        list(APPEND RELEASE_ARGS install)
        list(APPEND RELEASE_ARGS -g cmake_multi)
        list(APPEND RELEASE_ARGS -s build_type=Release)
        list(APPEND RELEASE_ARGS ${CONAN_SETTINGS})

        list(APPEND DEGUB_ARGS install)
        list(APPEND DEGUB_ARGS -g cmake_multi)
        list(APPEND DEGUB_ARGS -s build_type=Debug)
        list(APPEND DEGUB_ARGS ${CONAN_SETTINGS})

        if(MSVC)
            list(APPEND RELEASE_ARGS -s compiler.runtime=MD)
            list(APPEND DEGUB_ARGS -s compiler.runtime=MDd)
        endif(MSVC)

        if("${conan_version}" MATCHES "Conan version 1.")
            message("conan version : ${conan_version} is greater than 1.0")
            list(APPEND RELEASE_ARGS ${CMAKE_SOURCE_DIR}/conanfile.txt)
            list(APPEND DEGUB_ARGS ${CMAKE_SOURCE_DIR}/conanfile.txt)
        else()
            message("conan version : ${conan_version} is less than 1.0")
            list(APPEND RELEASE_ARGS -f ${CMAKE_SOURCE_DIR}/conanfile.txt)
            list(APPEND DEGUB_ARGS -f ${CMAKE_SOURCE_DIR}/conanfile.txt)
        endif()

        execute_process(COMMAND ${CONAN_EXECUTABLE} ${RELEASE_ARGS}
                        RESULT_VARIABLE result
                        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
        if(result)
            message(FATAL_ERROR "Conan install release failed: ${result}")
        endif(result)
                        
        execute_process(COMMAND ${CONAN_EXECUTABLE} ${DEGUB_ARGS}
                        RESULT_VARIABLE result
                        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
        if(result)
            message(FATAL_ERROR "Conan install debug failed: ${result}")
        endif(result)


        include(${CMAKE_BINARY_DIR}/conanbuildinfo_multi.cmake)
        CONAN_BASIC_SETUP()
        CONAN_BASIC_SETUP(TARGETS)
	endif()
endif()
