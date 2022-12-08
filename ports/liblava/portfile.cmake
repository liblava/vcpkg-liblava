vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test  LIBLAVA_TEST
        demo  LIBLAVA_DEMO
)

set(REF 0.7.3)
set(HEAD_REF master)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liblava/liblava
    REF ${REF}
    SHA512 ec2346a6085e58a69c79fe47918d60d55de0d9d1b466c94dddff2c1099327f4a0039ff0c7e31d914a77e0093e42b497191354aea304e34af768339a150a1666b
    HEAD_REF ${HEAD_REF}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBLAVA_TEMPLATE=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/liblava/base/test")

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/lava
    TARGET_PATH share/lava
)

if("test" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            lava
            lava-test
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
            lava-demo
            lava-triangle
            lava-generics
            lava-shapes
            lava-lamp
            lava-spawn
            lava-light
        AUTO_CLEAN
    )
endif()

configure_file(${CURRENT_PORT_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
