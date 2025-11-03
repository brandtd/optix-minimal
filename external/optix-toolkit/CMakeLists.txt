# Only the `vec_math.h` file from the OTK ShaderUtil--the full toolkit contains
# much more than I want to include in this minimal example, but the
# `vec_math.h` has stuff that's pretty surprising isn't baked-in to CUDA.

cmake_minimum_required(VERSION 3.23 FATAL_ERROR)
project(ShaderUtil LANGUAGES C CXX CUDA)
find_package( CUDAToolkit 10.0 REQUIRED )

add_library(ShaderUtil INTERFACE)
add_library(OptiXToolkit::ShaderUtil ALIAS ShaderUtil)

target_sources(ShaderUtil
  PUBLIC
  FILE_SET HEADERS
  BASE_DIRS include
  FILES
    include/OptiXToolkit/ShaderUtil/vec_math.h
)
target_include_directories(ShaderUtil
  INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/include
)
target_link_libraries(ShaderUtil INTERFACE OptiX::OptiX)
