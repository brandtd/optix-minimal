add_library(OptiX INTERFACE)
add_library(OptiX::OptiX ALIAS OptiX)
target_include_directories(OptiX INTERFACE "${CMAKE_CURRENT_LIST_DIR}/optix-dev/include")

add_subdirectory(optix-toolkit)
