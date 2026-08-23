# angle-builds

Prebuilt [ANGLE](https://chromium.googlesource.com/angle/angle) libraries for
macOS (arm64) and Windows (x64), built from pinned upstream commits with
GitHub Actions.

Starting with Chromium 151, official Chromium builds link ANGLE statically and
ship only stub `libEGL`/`libGLESv2` libraries with empty export tables, so
CEF and other Chromium distributions are no longer a usable source of these
libraries. This repository builds them directly from ANGLE source.

## Releases

Each release is tagged `vYYYYMMDD-<commit>` and contains:

- `angle-macos-arm64.zip` — `libEGL.dylib`, `libGLESv2.dylib`, `ANGLE-LICENSE.txt`
- `angle-windows-x64.zip` — `libEGL.dll`, `libGLESv2.dll`, `ANGLE-LICENSE.txt`
  (plus `d3dcompiler_47.dll` when produced by the build)

## Building a release

The ANGLE commit is pinned as `ANGLE_SHA` in `platforms/config.sh`, and each
platform builds through its own `platforms/<platform>/external.sh` (also
runnable locally). To cut a release, bump the pin and run the `Build ANGLE`
workflow from the Actions tab; it builds both platforms and publishes a
release with the artifacts.

Pin commits from an ANGLE release branch (`chromium/NNNN`) rather than `main`:
upstream `main` may require a Windows SDK that is not yet installable on CI
runners.

## License

The workflow and scripts in this repository are MIT licensed. ANGLE itself is
BSD-3-Clause; its license is included in every artifact as
`ANGLE-LICENSE.txt`.
