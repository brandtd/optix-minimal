# OptiX Minimal Project

This repo contains a minimal setup for getting an NVIDIA OptiX application going. It takes code from [optix-subd](https://github.com/nvidia/optix-subd) and rips out as much as possible to leave the repo with:

1. Access to the OptiX SDK
2. The ability to compile and embed shader code
3. No `FetchContent` calls inside the cmake files so that a single `git clone` is all the internet access that should be needed to get going
4. No GUI (i.e., OpenGL) libraries

_NOTE_: I have only tried this on a Windows machine, so I'm unsure what changes may be needed to compile and run on a Linux machine. As of this writing (Nov 3, 2025) containers (docker/podman) aren't supported because the OptiX runtime is very finicky--I could not get it working inside a Podman managed container under a Windows 11 host.

## Building

These steps are copied from the [optix-subd](https://github.com/nvidia/optix-subd) repo:

1. Clone the repo with (recursive to get the OptiX dev repo)

  `git clone --recursive https://github.com/brandtd/optix-min`

2. Use CMake to configure and build the project files with

  ```ps
  cmake CMakeLists.txt -B ./build -DCMAKE_BUILD_TYPE=Release
  cmake --build ./build
  ```

3. Run the executable with

  `./build/bin/optix-min`

