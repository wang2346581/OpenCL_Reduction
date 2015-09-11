void vector_add(__global float *a, __global float *b, __global float *res)
{
    *res = *a + *b;
}

__kernel void adder(__global const float* a, __global const float* b, __global float* result)
{
	int idx = get_global_id(0);

    result[idx] = 0;
    vector_add(&a[idx], &b[idx], &result[idx]);
}
__kernel void reduce(__global float* buffer, __local float* scratch,__const int length,__global float* result) 
{
  int global_index = get_global_id(0);
  int local_index = get_local_id(0);
 
  // Load data into local memory
  if (global_index < length) {
    scratch[local_index] = buffer[global_index];
  } else {
    // Infinity is the identity element for the min operation
    scratch[local_index] = INFINITY;
  }
  barrier(CLK_LOCAL_MEM_FENCE);
 

  for(int offset = 1;offset < get_local_size(0);offset <<= 1) {
    int mask = (offset << 1) - 1;
    if ((local_index & mask) == 0) {
      float other = scratch[local_index + offset];
      float mine = scratch[local_index];
      scratch[local_index] = (mine < other) ? mine : other;
    }
    barrier(CLK_LOCAL_MEM_FENCE);
  }
  //if (local_index == 0 {
    result[global_index] = scratch[local_index];
  //}
}
