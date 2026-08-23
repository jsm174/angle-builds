# angle-builds

Prebuilt [ANGLE](https://chromium.googlesource.com/angle/angle) libraries for
macOS (arm64) and Windows (x64), built from pinned upstream commits with
GitHub Actions.

Starting with Chromium 151, official Chromium builds link ANGLE statically and
ship only stub `libEGL`/`libGLESv2` libraries with empty export tables, so
CEF and other Chromium distributions are no longer a usable source of these
libraries. This repository builds them directly from ANGLE source.

## Building

The ANGLE commit is pinned as `ANGLE_SHA` in `platforms/config.sh`.
`platforms/<platform>/external.sh` fetches depot_tools and the pinned ANGLE
source, builds `libEGL`/`libGLESv2`, and stages them with the ANGLE license
into `dist/<platform>/`.

Pin commits from an ANGLE release branch (`chromium/NNNN`) rather than `main`:
upstream `main` may require a Windows SDK that is not yet installable.

<details open>
<summary>windows-x64</summary>

Requires Visual Studio 2022 or newer with the Desktop development with C++
workload, a Windows 10/11 SDK, Python 3, and Git for Windows. Build from Git
Bash:

```shell
git clone git@github.com:jsm174/angle-builds.git
cd angle-builds
platforms/windows-x64/external.sh
```
</details>

<details>
<summary>macos-arm64</summary>

Requires Xcode 16 or newer and Python 3.

```shell
git clone git@github.com:jsm174/angle-builds.git
cd angle-builds
platforms/macos-arm64/external.sh
```
</details>

## Releases

To cut a release, bump `ANGLE_SHA` in `platforms/config.sh` and run the
`Build ANGLE` workflow from the Actions tab. Each release is tagged
`vYYYYMMDD-<commit>` and contains:

- `angle-macos-arm64.tar.gz` — `libEGL.dylib`, `libGLESv2.dylib`, `ANGLE-LICENSE.txt`
- `angle-windows-x64.zip` — `libEGL.dll`, `libGLESv2.dll`, `ANGLE-LICENSE.txt`
  (plus `d3dcompiler_47.dll` when produced by the build)

## License

The workflow and scripts in this repository are MIT licensed. ANGLE itself is
BSD-3-Clause; its license is included in every artifact as
`ANGLE-LICENSE.txt`.
