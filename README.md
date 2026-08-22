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

Run the `build` workflow from the Actions tab. The `angle_ref` input accepts a
branch, tag, or full commit sha from the upstream ANGLE repository; it defaults
to `main`. The workflow resolves the ref to a commit, builds both platforms,
and publishes a release with the artifacts.

## License

The workflow and scripts in this repository are MIT licensed. ANGLE itself is
BSD-3-Clause; its license is included in every artifact as
`ANGLE-LICENSE.txt`.
