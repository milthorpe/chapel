/*
 * Copyright 2020-2024 Hewlett Packard Enterprise Development LP
 * Copyright 2004-2019 Cray Inc.
 * Other additional copyright holders may be indicated within.  *
 * The entirety of this work is licensed under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 *
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifdef HAS_GPU_LOCALE

#include <cuda.h>
#include <cub/cub.cuh>

#include "chpl-gpu.h"
#include "chpl-gpu-impl.h"
#include "../common/cuda-utils.h"
#include "gpu/chpl-gpu-reduce-util.h"

// this version doesn't do anything with `idx`. Having a unified interface makes
// the implementation in the rest of the runtime and the modules more
// straightforward.
#define DEF_ONE_REDUCE_RET_VAL(cub_kind, chpl_kind, data_type) \
void chpl_gpu_impl_##chpl_kind##_reduce_##data_type(data_type* data, int n,\
                                                    data_type* val, int* idx,\
                                                    void* stream) {\
  CUdeviceptr result; \
  CUDA_CALL(cuMemAlloc(&result, sizeof(data_type))); \
  void* temp = NULL; \
  size_t temp_bytes = 0; \
  cub::DeviceReduce::cub_kind(temp, temp_bytes, data, (data_type*)result, n,\
                              (CUstream)stream); \
  CUDA_CALL(cuMemAlloc(((CUdeviceptr*)&temp), temp_bytes)); \
  cub::DeviceReduce::cub_kind(temp, temp_bytes, data, (data_type*)result, n,\
                              (CUstream)stream); \
  CUDA_CALL(cuMemcpyDtoHAsync(val, result, sizeof(data_type),\
                              (CUstream)stream)); \
  CUDA_CALL(cuMemFree(result)); \
}

GPU_IMPL_REDUCE(DEF_ONE_REDUCE_RET_VAL, Sum, sum)
GPU_IMPL_REDUCE(DEF_ONE_REDUCE_RET_VAL, Min, min)
GPU_IMPL_REDUCE(DEF_ONE_REDUCE_RET_VAL, Max, max)

#undef DEF_ONE_REDUCE_RET_VAL

#define DEF_ONE_REDUCE_RET_VAL_IDX(cub_kind, chpl_kind, data_type) \
void chpl_gpu_impl_##chpl_kind##_reduce_##data_type(data_type* data, int n,\
                                                    data_type* val, int* idx,\
                                                    void* stream) {\
  using kvp = cub::KeyValuePair<int,data_type>; \
  CUdeviceptr result; \
  CUDA_CALL(cuMemAlloc(&result, sizeof(kvp))); \
  void* temp = NULL; \
  size_t temp_bytes = 0; \
  cub::DeviceReduce::cub_kind(temp, temp_bytes, data, (kvp*)result, n,\
                              (CUstream)stream);\
  CUDA_CALL(cuMemAlloc(((CUdeviceptr*)&temp), temp_bytes)); \
  cub::DeviceReduce::cub_kind(temp, temp_bytes, data, (kvp*)result, n,\
                              (CUstream)stream);\
  kvp result_host; \
  CUDA_CALL(cuMemcpyDtoHAsync(&result_host, result, sizeof(kvp),\
                              (CUstream)stream)); \
  *val = result_host.value; \
  *idx = result_host.key; \
  CUDA_CALL(cuMemFree(result)); \
}

GPU_IMPL_REDUCE(DEF_ONE_REDUCE_RET_VAL_IDX, ArgMin, minloc)
GPU_IMPL_REDUCE(DEF_ONE_REDUCE_RET_VAL_IDX, ArgMax, maxloc)

#undef DEF_ONE_REDUCE_RET_VAL_IDX

#undef DEF_REDUCE

#endif // HAS_GPU_LOCALE

