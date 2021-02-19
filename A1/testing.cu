%%cu
#include <stdio.h>
#include <cuda.h>
#define N 1000

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

int main(){
    int A[N], B[N], C[N];
    for(int i = 0; i < N; ++i)
    {
       A[i] = i+1;
        B[i] = 2*i+2;
        C[i] = 0;
    }
    int* gpuA, *gpuB, *gpuC;
    cudaMalloc(&gpuA, sizeof(int) * N);
    cudaMalloc(&gpuB, sizeof(int) * N);
    cudaMalloc(&gpuC, sizeof(int) * N);

    cudaMemcpy(gpuA, A, sizeof(int) * N, cudaMemcpyHostToDevice);
    cudaMemcpy(gpuB, B, sizeof(int) * N, cudaMemcpyHostToDevice);
    cudaMemcpy(gpuC, C, sizeof(int) * N, cudaMemcpyHostToDevice);

    per_element_kernel<<<10, 128>>>(20,50,gpuA,gpuB,gpuC);
    cudaThreadSynchronize();	
	cudaMemcpy(C, gpuC, sizeof(int) * N, cudaMemcpyDeviceToHost);

    for(int i = 0; i < N; ++i)
    {
        printf("%d ",C[i]);
      if((i+1)%50==0)
        printf("\n");
    }

}