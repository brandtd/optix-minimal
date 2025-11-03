cmake_minimum_required(VERSION 3.27.7 FATAL_ERROR)

set(CMAKE_CUDA_ARCHITECTURES "86" CACHE STRING "")
project(optix-min
  LANGUAGES C CXX CUDA
  VERSION 0.1.0
)

message(STATUS "CMAKE_CUDA_ARCHITECTURES: ${CMAKE_CUDA_ARCHITECTURES}")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CUDA_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

if (MSVC)
  add_compile_options($<$<COMPILE_LANGUAGE:CXX>:/we4099>)  # mixing struct/class forward decl

  # Optix files will include Windows.h, so try to minimize the damage ...
  add_definitions(-DNOMINMAX)
endif()

# CUDA
add_compile_options($<$<COMPILE_LANGUAGE:CUDA>:--use_fast_math>)
add_compile_options($<$<COMPILE_LANGUAGE:CUDA>:--expt-relaxed-constexpr>)
add_compile_options($<$<COMPILE_LANGUAGE:CUDA>:--expt-extended-lambda>)

add_compile_options($<$<AND:$<CONFIG:Debug>,$<COMPILE_LANGUAGE:CUDA>>:-G>)
add_compile_options($<$<AND:$<CONFIG:Debug>,$<COMPILE_LANGUAGE:CUDA>>:-lineinfo>)
add_compile_options($<$<AND:$<CONFIG:Release>,$<COMPILE_LANGUAGE:CUDA>>:-lineinfo>)

find_package(CUDAToolkit 12.0 REQUIRED)

add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/external)

include(cmake/embed_cuda.cmake)

option(PROJECT_ENABLE_OPTIXIR "Enable OptiXIR compilation" ON)
if (PROJECT_ENABLE_OPTIXIR)
  set(PROJECT_CUDA_COMPILATION_OUTPUT_TYPE "OPTIXIR")
else()
  set(PROJECT_CUDA_COMPILATION_OUTPUT_TYPE "PTX")
endif()

set(project_optix_src_files src/shaders.cu)
set(project_optix_hdr_files ProjectEmbeddedShaderCode.h)
set(project_optix_libraries OptiXToolkit::ShaderUtil)
set(project_optix_embedded_names kEmbeddedShaderCode)

embed_cuda(
  RELOCATABLE
  OUTPUT_TARGET
    project_embedded_device_code
    ${PROJECT_CUDA_COMPILATION_OUTPUT_TYPE}
  LIBRARIES
    ${project_optix_libraries}
  INCLUDES
    "${CMAKE_CURRENT_LIST_DIR}/src"
    include
  SOURCES
    ${project_optix_src_files}
  HEADER
    ${project_optix_hdr_files}
  EMBEDDED_SYMBOL_NAMES
    ${project_optix_embedded_names}
)

if (MSVC)
    target_compile_definitions(project_embedded_device_code PRIVATE _USE_MATH_DEFINES)
    target_compile_definitions(project_embedded_device_codeCuda PRIVATE _USE_MATH_DEFINES)
endif()

add_executable(project
  src/main.cc

  src/params.h
)

target_include_directories(project
  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_BINARY_DIR}/generated
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(project
  PRIVATE
    project_embedded_device_code
    OptiX::OptiX
    OptiXToolkit::ShaderUtil
    CUDA::cuda_driver
    CUDA::cudart
    ${CMAKE_DL_LIBS}
)

set_target_properties(project PROPERTIES CUDA_SEPARABLE_COMPILATION ON )

if (WIN32)
  # Set project as the startup project in MSVC
  set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT project)

  # Copy shared libraries that the built executable depends on.
  # Minimal example has no runtime dependencies
  #add_custom_command(
  #  TARGET project
  #  POST_BUILD
  #    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:project> $<TARGET_FILE_DIR:project>
  #    COMMAND_EXPAND_LISTS
  #)
endif()
