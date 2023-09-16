INCLUDE_GUARD()

IF(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
    MESSAGE(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
    FILE(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/master/conan.cmake"
         "${CMAKE_BINARY_DIR}/conan.cmake"
    )
ENDIF()

INCLUDE(${CMAKE_BINARY_DIR}/conan.cmake)

FIND_PACKAGE(
    Python 3
    COMPONENTS Interpreter Development NumPy
    REQUIRED QUIET
)

EXECUTE_PROCESS(
    COMMAND ${Python_EXECUTABLE} -m site --user-base
    OUTPUT_VARIABLE Python_USERBASE
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

SET(Python_USERBASEBIN
    ${Python_USERBASE}/bin
    CACHE FILEPATH "" FORCE
)

FIND_PROGRAM(conan_EXECUTABLE conan PATH ${Python_USERBASE}/bin)

# EXECUTE_PROCESS(
#     COMMAND ${conan_EXECUTABLE} remote list
#     OUTPUT_VARIABLE output
#     RESULT_VARIABLE result
# )

# IF(result)
#     ERROR("Failed to execute 'conan remote list' command")
# ENDIF()

# STRING(REPLACE "\n" ";" output ${output})

# FOREACH(line ${output})
#     STRING(REGEX MATCH "bincrafters" found ${line})
#     IF(found)
#         SET(remote_found TRUE)
#     ENDIF()
# ENDFOREACH()

# IF(NOT remote_found)
#     EXECUTE_PROCESS(
#         COMMAND ${conan_EXECUTABLE} remote add bincrafters https://api.bintray.com/conan/bincrafters/public-conan
#         OUTPUT_VARIABLE output
#         RESULT_VARIABLE result
#     )

#     IF(result)
#         MESSAGE(ERROR "Failed to execute 'conan remote add bincrafters https://api.bintray.com/conan/bincrafters/public-conan' command")
#     ENDIF()
# ENDIF()


CONAN_CMAKE_AUTODETECT(settings)

IF(BUILD_EMSCRIPTEN)
    CONAN_CMAKE_INSTALL(PATH_OR_REFERENCE ${CMAKE_SOURCE_DIR} BUILD missing SETTINGS ${settings} PROFILE ${CMAKE_SOURCE_DIR}/conanfile.emscripten.profile)
ELSE()
    CONAN_CMAKE_INSTALL(PATH_OR_REFERENCE ${CMAKE_SOURCE_DIR} BUILD missing SETTINGS ${settings})
ENDIF()

INCLUDE(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)

INCLUDE(${CMAKE_BINARY_DIR}/conan_paths.cmake)

CONAN_DEFINE_TARGETS()
