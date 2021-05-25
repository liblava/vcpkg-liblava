vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test  LIBLAVA_TESTS
        demo  LIBLAVA_DEMO
)

set(REF 0.6.2)
set(HEAD_REF master)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liblava/liblava
    REF ${REF}
    SHA512 f9ef2e5837fdda5714a3c7d94ec9499c6ce8c79bd56a1055259100798141ec8646875e34f0ece0f95e163a76eaf50e8e49ac34a7570a02776c9beba512c12383
    HEAD_REF ${HEAD_REF}
)

# vcpkg_from_github or vcpkg_from_git don't download submodules and get rid of the .git folder
# restore it and update submodules

if(NOT EXISTS "${SOURCE_PATH}/.git")
    message(STATUS "Updating submodules")

    if(VCPKG_USE_HEAD_VERSION)
        set(CLONE_REF ${HEAD_REF})
    else()
        set(CLONE_REF ${REF})
    endif()

    vcpkg_find_acquire_program(GIT)

    set(COMMANDS
        "${GIT} clone --depth 1 --branch ${CLONE_REF} --bare https://github.com/liblava/liblava.git .git"
        "${GIT} config core.bare false"
        "${GIT} reset --hard"
        "${GIT} submodule update --init --recursive"
    )

    foreach(COMMAND ${COMMANDS})
        separate_arguments(COMMAND)
        vcpkg_execute_required_process(
            ALLOW_IN_DOWNLOAD_MODE
            COMMAND ${COMMAND}
            WORKING_DIRECTORY ${SOURCE_PATH}
            LOGNAME update-submodules
        )
    endforeach()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBLAVA_TEMPLATE=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/lava
    TARGET_PATH share/lava
)

if("test" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            lava
            lava-unit
        AUTO_CLEAN
    )
endif()

if("demo" IN_LIST FEATURES)
    file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/res DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})

    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin/res"
        "${CURRENT_PACKAGES_DIR}/debug/bin/res"
    )

    vcpkg_copy_tools(
        TOOL_NAMES
            lava-triangle
            lava-lamp
            lava-spawn
            lava-light
        AUTO_CLEAN
    )
endif()

configure_file(${CURRENT_PORT_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
