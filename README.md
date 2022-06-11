# Vcpkg registry and port for [liblava](https://github.com/liblava/liblava).

liblava is a modern and easy-to-use library for the Vulkan® API

# Install

## Option A: Registry

In [manifest mode](https://github.com/microsoft/vcpkg/blob/master/docs/users/manifests.md), this repository can be used as a custom registry with [versioning](https://github.com/microsoft/vcpkg/blob/master/docs/examples/versioning.getting-started.md) support.

### Add registry

Add this repository to *vcpkg-configuration.json* as a git [registry](https://github.com/microsoft/vcpkg/blob/master/docs/users/registries.md):

```json
{
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/liblava/vcpkg-liblava",
      "baseline": "!!!SEE BELOW!!!",
      "packages": [ "liblava" ]
    }
  ]
}
```

**The baseline must be a git commit ID from this repository.** To use the latest version, run:

```bash
git ls-remote https://github.com/liblava/vcpkg-liblava main
```

and copy the 40-character hash as the baseline string.

### Add dependency

Add liblava to *vcpkg.json* as a dependency:

```json
{
  "name": "my-application",
  "version": "1.0.0",
  "dependencies": [
    "liblava"
  ]
}
```

## Option B: Overlay

If you're using vcpkg in classic mode without manifests, clone this repo and pass a [port overlay](https://github.com/microsoft/vcpkg/blob/master/docs/specifications/ports-overlay.md) to vcpkg:

```bash
vcpkg install liblava --overlay-ports=/path/to/vcpkg-liblava/ports/liblava
```

**Note: Installing lava this way is discouraged. This port builds dependencies as submodules rather than using existing vcpkg ports. These submodule libraries may conflict with existing ports installed globally.**

# Usage

## Vcpkg integration

When you run CMake for your project, pass `-DCMAKE_TOOLCHAIN_FILE=/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake`. This will make all installed libraries available to CMake.

If you're not using CMake or need advanced configuration, refer to [Buildsystem Integration](https://github.com/microsoft/vcpkg/blob/master/docs/users/integration.md).

## Linking

In your CMakeLists.txt, find and link to lava:

```cmake
find_package(lava CONFIG REQUIRED)
target_link_libraries(main PRIVATE lava::engine)
```

# Features

The following optional features can be configured:

| Option  | Description                          |
|---------|--------------------------------------|
| test    | Build and install lava test binaries |
| demo    | Build and install lava demo binaries |

For information on how to set them, refer to [Selecting library features](https://github.com/microsoft/vcpkg/blob/master/docs/users/selecting-library-features.md).

# New version

To add a new [tagged lava version](https://github.com/liblava/liblava/tags):

1. Modify ports/liblava/vcpkg.json
    - update version field
2. Modify ports/liblava/portfile.cmake
    - update REF variable
    - update SHA512 field - the easiest way is to try to install (see Option B above) and then copy the correct hash from the vcpkg error message (yes, really :eyes:)
    - if necessary, adapt to any changes to lava's build system
3. Commit changes
    - this is necessary to get an up-to-date git-tree ID in the next step
3. Modify versions/l-/liblava.json
    - add a new version
      - update version field
      - set git-tree field to the output of `git rev-parse HEAD:ports/liblava`
4. Modify versions/baseline.json
    - update baseline field
5. Commit changes with --amend
