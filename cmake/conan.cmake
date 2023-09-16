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

CONAN_CMAKE_AUTODETECT(settings)

CONAN_CMAKE_INSTALL(PATH_OR_REFERENCE ${CMAKE_BINARY_DIR} BUILD missing SETTINGS ${settings})

INCLUDE(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)

INCLUDE(${CMAKE_BINARY_DIR}/conan_paths.cmake)

CONAN_DEFINE_TARGETS()
