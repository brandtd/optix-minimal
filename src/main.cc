#include <cstdlib>
#include <iostream>

#include <cuda_runtime_api.h>
#include <optix.h>
#include <optix_function_table_definition.h>
#include <optix_stubs.h>
#include <OptiXToolkit/ShaderUtil/vec_math.h>

int main(int argc, char** argv)
{
  int result{EXIT_FAILURE};

  if (cudaFree(0) == cudaSuccess) {
    if (optixInit() == OPTIX_SUCCESS) {
      std::cout << "CUDA/OptiX initialized" << std::endl;
      result = EXIT_SUCCESS;
    } else { std::cerr << "Failed to initialize OptiX" << std::endl; }
  } else { std::cerr << "Failed to initialize CUDA" << std::endl; }

  return result;
}
