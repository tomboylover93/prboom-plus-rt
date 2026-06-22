## Build

### 1. Install dependencies

**Debian/Ubuntu**
```bash
sudo apt install build-essential cmake python3 libsdl2-dev libvulkan-dev \
  libshaderc-dev libgl1-mesa-dev libglu1-mesa-dev libmad0-dev libfluidsynth-dev \
  libdumb1-dev libogg-dev libvorbis-dev libportmidi-dev libasound2-dev
```

**Fedora**
```bash
sudo dnf install cmake gcc-c++ python3 SDL2-devel vulkan-devel shaderc-devel \
  mesa-libGL-devel mesa-libGLU-devel libmad-devel fluidsynth-devel \
  dumb-devel libogg-devel libvorbis-devel portmidi-devel alsa-lib-devel
```

**Arch Linux**
```bash
sudo pacman -S --needed base-devel cmake python sdl2 vulkan-devel shaderc \
  glu libmad fluidsynth dumb libogg libvorbis portmidi alsa-lib
```

### 2. Clone the repositories

```bash
git clone https://github.com/tomboylover93/prboom-plus-rt
cd prboom-plus-rt/prboom2
# add --recursive after git clone if you want to build the test and example targets
git clone https://github.com/tomboylover93/RayTracedGL1 -b doom
```

### 3. Build the RTGL1 library

```bash
cd RayTracedGL1
cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DRG_WITH_SURFACE_XLIB=ON \
  -DRG_WITH_SURFACE_WAYLAND=ON
cmake --build build -j$(nproc)
```

#### 3.1. About NVIDIA DLSS

Follow the instructions above and also add `-DRG_USE_NVIDIA_DLSS=ON` to the `cmake` command. Do note that you need to clone the NVIDIA DLSS SDK repository from [here](https://github.com/NVIDIA/DLSS). I believe the specific version you need is DLSS 2.x, and they are kind enough to provide pre-built .so files: https://github.com/NVIDIA/DLSS/tree/v2.4.0/lib/Linux_x86_64/rel 

### 4. Build prboom-rt

```bash
cd ..
export RTGL1_SDK_PATH=$(pwd)/RayTracedGL1
cmake -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build build -j$(nproc)
```

### 5. Quick setup

Download the latest prerelease from sultim-t's original repository [here](https://github.com/sultim-t/prboom-plus-rt/releases/download/v2.6.1-rt1.0.7/prboom-rt-1.0.7.zip) or the latest release from this repository's [releases page](https://github.com/tomboylover93/prboom-plus-rt/releases/latest) and extract the ovrd/ folder to your build directory. Then place your DOOM.WAD in the build directory, or specify another path as shown below.

### 6. Launch

```bash
# launcher with IWAD picker (if installed system-wide)
prboom-rt-launcher

# or run directly
./build/prboom-plus -iwad /path/to/doom.wad
```

### 7. System-wide install (optional)

```bash
sudo cmake --install build --prefix /usr
# if you don't want to use /usr, specify a different prefix (e.g. /opt)
sudo cmake --install build --prefix /opt
```

It will also install a `prboom-rt-launcher` script that lets you pick your IWAD of choice at startup. You need [fzf](https://github.com/junegunn/fzf) for this.
Then place your IWAD files and RT assets (ovrd folder) in `/usr/share/prboom-rt/` (or wherever you installed it to).
The `install.sh` script at the root of the repository is meant to be used for the packages in the releases page. It is not meant to be used for building from source.
