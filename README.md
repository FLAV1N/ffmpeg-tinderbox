Essentially it's a tool, tinderbox, that automates the process of checking out and building a recent FFmpeg source code, including nonfree libraries such as libfdk-aac and decklink.

For a manual build, follow detailed instructions below:

---

##  Prelude

A fork of [ffmpeg-tinderbox](https://github.com/nanake/ffmpeg-tinderbox). Builds nonfree libraries such as libfdk-aac and decklink. While also including gimmick and modified encoders such as:

- [aom-av1-lavish](https://github.com/Clybius/aom-av1-lavish/tree/Endless_Merging) (libaom) "Endless_Merging" branch for psychovisual benefits and sane defaults.
- [rav1e](https://github.com/Simulping/rav1e) (librav1e) with quietvoid's Dolby Vision patch applied.
- [SVT-AV1](https://github.com/gianni-rosato/svt-av1-psy) (libsvtav1) fork by Gianni Rosato & Co. for psychovisual goodies, variance modifications, low luma bias, photon noise support, etc.
- [VVenC](https://github.com/fraunhoferhhi/vvenc) (libvvenc)
- [VVdeC](https://github.com/fraunhoferhhi/vvdec) (libvvdec)
- Dolby AC-4 decode support.

Currently, the FFmpeg version being used is release 6.1 because it's the latest stable version that works with the custom VVenC patch, so unless upstream makes the patch always compatible, It's stuck using Fraunhofer's VVenC [wiki](https://github.com/fraunhoferhhi/vvenc/wiki/FFmpeg-Integration) for guidance. 

***Requirements***

Ensure you have the following tools installed on your system:

- **Bash**
- **Docker**

***Targets, Variants and Addins***

#### Targets:

- `win64`: Build for 64-bit Windows
- `win32`: Build for 32-bit Windows

#### Variants:

- `gpl`: Builds all libraries from `scripts.d` folder *except* `libfdk-aac` and `decklink`
- `lgpl`: Excludes additional libraries (`avisynth`, `davs2`, `vidstab`, `x264`, `x265` and `xavs2`)
- `nonfree`: Includes both non-free libraries (`libfdk-aac` and `decklink`) and all libraries of the gpl variant

#### Addins:

- `debug`: Adds debug symbols to the build. It's `gdb` compatible embedded debug info

##  Building

1. Build base-image:

```console
docker build -t ghcr.io/nanake/base-${TARGET}:latest images/base-${TARGET}
```

*Note:* You might need to modify the *rootfs* image by specifying a public image base, such as `fedora:rawhide`.

2. Build target-variant image:

```console
./generate.sh ${TARGET} ${VARIANT}
docker build -t ghcr.io/nanake/${TARGET}-${VARIANT}:latest .
```
*Alternatively*, You can build both *base-image* and *target-variant* image by simply invoke `makeimage.sh`. For example:

```console
./makeimage.sh win64 nonfree
```

3. Build FFmpeg

```console
./build.sh ${TARGET} ${VARIANT} ${ADDINS}
```
To create a `shared` build of FFmpeg, append `-shared` to the `VARIANT` name. For example:

```console
./build.sh win64 gpl-shared
```
Upon successful build completion, the build artifacts will be available in the `artifacts` folder.

---

###  Acknowledgments

The foundation for this build script comes from the work of [BtbN](https://github.com/BtbN/FFmpeg-Builds).

