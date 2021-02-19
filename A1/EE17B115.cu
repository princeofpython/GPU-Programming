#ifndef _KERNELS_H_
#define _KERNELS_H_

__global__ void per_row_kernel(int m,int n,int *A,int *B,int *C){  

    unsigned long long row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < m){
        for(unsigned long long i = 0; i < n; ++i){
            C[row*n + i] = A[row*n + i] + B[row*n + i];  
        }
    }
}

__global__ void per_column_kernel(int m,int n,int *A,int *B,int *C){  
    unsigned long long col = (blockIdx.x * blockDim.y + threadIdx.y) * blockDim.x + threadIdx.x;
    if (col < n){
        for(unsigned long long i = 0; i < m; ++i){
            C[i*n + col] = A[i*n + col] + B[i*n + col]; 
        }
    }
}  
__global__ void per_element_kernel(int m,int n,int *A,int *B,int *C){
    unsigned long long id = ((blockIdx.y*gridDim.x+blockIdx.x)*(blockDim.x*blockDim.y))+(threadIdx.y*blockDim.x+threadIdx.x);
    if (id < m*n){
        C[id] = A[id] + B[id];
    }
}
#endif
