CMAKE_MINIMUM_REQUIRED(VERSION 3.25)

FIND_PACKAGE(Git)

EXECUTE_PROCESS(
    COMMAND ${CMAKE_COMMAND} -D SRC=${CMAKE_SOURCE_DIR}/inc/imageloaderversion.h.in -D DST=${CMAKE_BINARY_DIR}/imageloaderversion.h -D GIT_EXECUTABLE=${GIT_EXECUTABLE} -P ${CMAKE_SOURCE_DIR}/cmake/version.cmake
    OUTPUT_VARIABLE IMAGES_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

PROJECT(
    ImagesLoader
    LANGUAGES CXX
    VERSION ${IMAGES_VERSION}
)

OPTION(BUILD_EMSCRIPTEN "Build for Emscripten" OFF)

MESSAGE(STATUS "Project: ${PROJECT_NAME} - v${PROJECT_VERSION}")

IF(NOT CMAKE_BUILD_TYPE)
    SET(CMAKE_BUILD_TYPE Release)
ENDIF()

IF(BUILD_EMSCRIPTEN)
    ADD_DEFINITIONS(-DUSE_EMSCRIPTEN)
ELSE()
    INCLUDE(cmake/conan.cmake)
ENDIF()

FIND_PACKAGE(JPEG REQUIRED)
FIND_PACKAGE(PNG REQUIRED)
FIND_PACKAGE(WebP REQUIRED)

# INCLUDES
INCLUDE_DIRECTORIES(inc)
INCLUDE_DIRECTORIES(${CMAKE_BINARY_DIR})
INCLUDE_DIRECTORIES(${JPEG_INCLUDE_DIRS})
INCLUDE_DIRECTORIES(${PNG_INCLUDE_DIRS})
INCLUDE_DIRECTORIES(${WebP_INCLUDE_DIRS})

# GET THE SOURCE FILE
FILE(GLOB_RECURSE HDRS inc/*.h)
FILE(GLOB_RECURSE SRCS src/*.cpp)

ADD_EXECUTABLE(${PROJECT_NAME} ${HDRS} ${SRCS})

TARGET_LINK_LIBRARIES(${PROJECT_NAME} WebP::WebP)
TARGET_LINK_LIBRARIES(${PROJECT_NAME} PNG::PNG)
TARGET_LINK_LIBRARIES(${PROJECT_NAME} JPEG::JPEG)

IF (BUILD_EMSCRIPTEN)
    SET(EXPORTED_RUNTIME_METHODS
        "['FS','stackAlloc','stackRestore','stackSave','UTF8ToString','stringToUTF8','lengthBytesUTF8']"
    )

    SET_TARGET_PROPERTIES(
        ${PROJECT_NAME}
        PROPERTIES
            LINK_FLAGS
            "\
-s \"EXPORTED_RUNTIME_METHODS=${EXPORTED_RUNTIME_METHODS}\" \
-s EXPORT_ES6=1                                             \
-s INITIAL_MEMORY=33554432                                  \
-s MAXIMUM_MEMORY=4294967296                                \
-s WASM=1                                                   \
-s NO_EXIT_RUNTIME=0                                        \
-s ALLOW_MEMORY_GROWTH=1                                    \
-s MODULARIZE=1                                             \
-s EXPORT_ALL=0                                             \
-s LLD_REPORT_UNDEFINED                                     \
-s VERBOSE=0                                                \
-s FORCE_FILESYSTEM=1                                       \
-s WARN_ON_UNDEFINED_SYMBOLS=1                              \
-s WASM=1                                                   \
-s EMBIND_STD_STRING_IS_UTF8=1                              \
-s FILESYSTEM=1                                             \
-s ENVIRONMENT=web,worker                                   \
--no-entry                                                  \
--bind")

    IF(CMAKE_BUILD_TYPE STREQUAL "Debug")
        SET_PROPERTY(
            TARGET ${PROJECT_NAME}
            APPEND_STRING
            PROPERTY LINK_FLAGS
                    " -s ASSERTIONS=2 -s SAFE_HEAP=1 -s STACK_OVERFLOW_CHECK=1 -s DEMANGLE_SUPPORT=1"
        )
        SET_PROPERTY(
            TARGET ${PROJECT_NAME}
            APPEND_STRING
            PROPERTY LINK_FLAGS " -s DISABLE_EXCEPTION_THROWING=0"
        )
    ELSE()
        SET_PROPERTY(
            TARGET ${PROJECT_NAME}
            APPEND_STRING
            PROPERTY LINK_FLAGS
                    " -s ASSERTIONS=0 -s SAFE_HEAP=0 -s STACK_OVERFLOW_CHECK=0 -s DEMANGLE_SUPPORT=0 -O3 -flto"
        )
    ENDIF()

    SET_PROPERTY(
        TARGET ${PROJECT_NAME}
        APPEND_STRING
        PROPERTY LINK_FLAGS " -s EXPORT_NAME=imgloader"
    )

    SET_TARGET_PROPERTIES(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "${PROJECT_NAME}.${PROJECT_VERSION}")
    SET_TARGET_PROPERTIES(${PROJECT_NAME} 
        PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/docs/dist/"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/docs/dist/"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/docs/dist/"
    )
ENDIF()