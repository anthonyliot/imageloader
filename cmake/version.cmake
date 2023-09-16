INCLUDE_GUARD()

GET_FILENAME_COMPONENT(SRC_DIR ${SRC} DIRECTORY)

# CONVERT A NUMBER TO HEXADECIMAL
FUNCTION(NUMBER_TO_HEXA)
    CMAKE_PARSE_ARGUMENTS(_ "" "" "NUMBER;OUTPUT_VARIABLE" ${ARGN})

    SET(chars "0123456789abcdef")
    SET(hex "")

    FOREACH(i RANGE 7)
        MATH(EXPR nibble "${__NUMBER} & 15")
        STRING(SUBSTRING "${chars}" "${nibble}" 1 nibble_hex)
        STRING(APPEND hex "${nibble_hex}")
        MATH(EXPR __NUMBER "${__NUMBER} >> 4")
    ENDFOREACH()

    STRING(REGEX REPLACE "(.)(.)" "\\2\\1" hex "${hex}")
    SET("${__OUTPUT_VARIABLE}"
        "${hex}"
        PARENT_SCOPE
    )
ENDFUNCTION()

# GET THE GIT SHA VERSION
EXECUTE_PROCESS(
    COMMAND git rev-parse HEAD
    OUTPUT_VARIABLE VERSION_GIT_SHA_LONG
    ERROR_QUIET
    WORKING_DIRECTORY ${SRC_DIR}
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# SHORTEN THE GIT SHA VERSION
STRING(SUBSTRING ${VERSION_GIT_SHA_LONG} 0 8 VERSION_GIT_SHA)
SET(VERSION_GIT_SHA ${VERSION_GIT_SHA})

EXECUTE_PROCESS(
    COMMAND git rev-parse --abbrev-ref HEAD
    OUTPUT_VARIABLE VERSION_NAME
    WORKING_DIRECTORY ${SRC_DIR}
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

EXECUTE_PROCESS(
    COMMAND git tag --sort=-creatordate
    OUTPUT_VARIABLE GIT_TAG_LIST
    ERROR_QUIET
    WORKING_DIRECTORY ${SRC_DIR}
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

IF(NOT "${GIT_TAG_LIST}" STREQUAL "")
    STRING(REPLACE "\n" ";" GIT_TAG_LIST ${GIT_TAG_LIST})
    FOREACH(TAG ${GIT_TAG_LIST})
        STRING(REPLACE "v" "" TAGL ${TAG})
        STRING(REPLACE "." ";" TAGL ${TAGL})
        LIST(LENGTH TAGL SIZE)
        MATH(EXPR LAST "${SIZE} - 1")
        LIST(GET TAGL ${LAST} MINOR)
        IF("${SIZE}" STREQUAL "4" AND "${MINOR}" STREQUAL "")
            STRING(STRIP "${TAG}" GIT_TAG)
            BREAK()
        ELSEIF("${SIZE}" STREQUAL "3")
            STRING(STRIP "${TAG}" GIT_TAG)
            BREAK()
        ENDIF()
    ENDFOREACH()

    EXECUTE_PROCESS(
        COMMAND git rev-list ${GIT_TAG}..HEAD --count
        OUTPUT_VARIABLE VERSION_POST
        ERROR_QUIET
        WORKING_DIRECTORY ${SRC_DIR}
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

ELSE()
    SET(GIT_TAG "v0.0")

    EXECUTE_PROCESS(
        COMMAND git rev-list --count HEAD
        OUTPUT_VARIABLE VERSION_POST
        ERROR_QUIET
        WORKING_DIRECTORY ${SRC_DIR}
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
ENDIF()

STRING(REPLACE "v" "" TAGL ${GIT_TAG})
STRING(REPLACE "." ";" TAGL ${TAGL})

LIST(GET TAGL 0 MAJOR)
LIST(GET TAGL 1 MINOR)
SET(SEMVER ${MAJOR}.${MINOR}.0-post.${VERSION_POST}+${VERSION_GIT_SHA})

STRING(STRIP "${SEMVER}" SEMVER)
STRING(REPLACE "+" "-" SEMVER_LIST ${SEMVER})
STRING(REPLACE "-" ";" SEMVER_LIST ${SEMVER_LIST})

LIST(GET SEMVER_LIST 0 SEMVER_BEGIN_PART)
STRING(REPLACE "." ";" SEMVER_BEGIN_PART_LIST ${SEMVER_BEGIN_PART})
LIST(GET SEMVER_BEGIN_PART_LIST 0 VERSION_MAJOR)
LIST(GET SEMVER_BEGIN_PART_LIST 1 VERSION_MINOR)

STRING(TIMESTAMP TIME "%Y%m%d")

SET(VERSION_STR_FULL
    "${VERSION_MAJOR}.${VERSION_MINOR}+${VERSION_GIT_SHA}"
)

SET(VERSION_STR_FULL_TIME
    "${VERSION_MAJOR}.${VERSION_MINOR}+${VERSION_GIT_SHA}.${TIME}"
)

# SHORT VERSION A.B.C
SET(VERSION_STR "${VERSION_MAJOR}.${VERSION_MINOR}")

# HEXA VERSION 0x0000000
STRING(REPLACE "." "" INT_VERSION ${VERSION_STR})
NUMBER_TO_HEXA(NUMBER ${INT_VERSION} OUTPUT_VARIABLE VERSION_HEX)
SET(VERSION_HEX "0x${VERSION_HEX}")

EXECUTE_PROCESS(
    COMMAND git rev-list --count HEAD
    OUTPUT_VARIABLE VERSION_INCR
    ERROR_QUIET
    WORKING_DIRECTORY ${SRC_DIR}
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

STRING(STRIP "${VERSION_INCR}" VERSION_INCR)
STRING(TIMESTAMP TODAY "%Y/%m/%d %H:%M")
CONFIGURE_FILE(${SRC} ${DST} @ONLY)

EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E echo ${VERSION_STR})