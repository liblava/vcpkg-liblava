vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test  LIBLAVA_TEST
        demo  LIBLAVA_DEMO
)

set(REF 0.7.2)
set(HEAD_REF master)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO liblava/liblava
    REF ${REF}
    SHA512 473e29686423c1da08ac5032294dbd9a721cda2abe47cb28e5b34dc75085431518e7cabcf741cc1beeb42eb9075e93e848584215d6a4a49620468825a126959c
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
