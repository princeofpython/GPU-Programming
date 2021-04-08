#include<stdio.h>
#include<stdlib.h>
#include<cuda.h>
#include <sys/time.h>
#include <thrust/sort.h>
#include <thrust/execution_policy.h>
#include <algorithm>
using namespace std;

#define BLOCKSIZE 1024

__global__ void initialize(pair<float, int> * gputimes, unsigned n){
    unsigned id = blockIdx.x * blockDim.x + threadIdx.x;
    if(id < n)
        gputimes[id].first = 0;
        gputimes[id].second = id;
}

__global__ void add_time(pair<float, int> * gputimes, unsigned vectorSize, int* gpuspeed, int i, int dis){
    unsigned id = blockIdx.x * blockDim.x + threadIdx.x;
    if(id < vectorSize)
        gputimes[id].first += 60* float(dis)/gpuspeed[i*vectorSize + gputimes[id].second];
}
__global__ void queue(pair<float, int> * gputimes, unsigned vectorSize, int x){
    unsigned id = threadIdx.x;
    for (int i =0; i < ceil(float(vectorSize)/blockDim.x); ++i){
        
        if(id + (i+1)* blockDim.x < vectorSize){
            if(gputimes[id + (i+1) * blockDim.x].first < gputimes[id + i * blockDim.x].first + x){
                gputimes[id + (i+1) * blockDim.x].first = gputimes[id + i * blockDim.x].first + x;
            }
        }
        gputimes[id + i * blockDim.x].first = gputimes[id + i * blockDim.x].first + x;
    }
}

//Complete the following function
void operations ( int n, int k, int m, int x, int dis, int *speed, int **results )  {
    pair<float, int> *times = (pair<float, int> *) malloc ( n * sizeof (pair<float, int>) );
    
    pair<float, int> *gputimes;
    int *gpuspeed;
    cudaMalloc(&gputimes, n * sizeof (pair<float, int>));

    cudaMalloc(&gpuspeed,  n*( k+1 ) * sizeof (int));
    cudaMemcpy(gpuspeed, speed,  n*( k+1 ) * sizeof (int), cudaMemcpyHostToDevice);

    unsigned nblocks = ceil(float(n) / BLOCKSIZE);
    //initialization
    cudaMemcpy(gputimes, times, n * sizeof (pair<float, int>), cudaMemcpyHostToDevice);
    initialize<<<nblocks, BLOCKSIZE>>>(gputimes, n);
    cudaDeviceSynchronize();
    cudaMemcpy(times, gputimes, n * sizeof (pair<float, int>), cudaMemcpyDeviceToHost);
    
    for (int i = 0; i < k+1; ++i){
        /*
        cudaMemcpy(gputimes, times, n * sizeof (pair<float, int>), cudaMemcpyHostToDevice);
        add_time<<<nblocks, BLOCKSIZE>>>(gputimes, n, gpuspeed, i, dis);
        cudaMemcpy(times, gputimes, n * sizeof (pair<float, int>), cudaMemcpyDeviceToHost);
        cudaDeviceSynchronize();
        */
        for(int j = 0; j< n; j++){
            times[j].first += 60* float(dis)/speed[i*n + times[j].second];
        }
        thrust::sort(thrust::host, times, times + n);
        //sort(times, times+ n);
        results[0][i] = times[0].second+1;
        results[1][i] = times[n-1].second+1;
        cudaMemcpy(gputimes, times, n * sizeof (pair<float, int>), cudaMemcpyHostToDevice);
        queue<<<1, m>>>(gputimes, n, x);
        cudaDeviceSynchronize();
        cudaMemcpy(times, gputimes, n * sizeof (pair<float, int>), cudaMemcpyDeviceToHost);

    }

    for(int i = 0; i< n; ++i){
        results[2][times[i].second] = int(times[i].first) - x; 
    }

}

int main(int argc,char **argv){

    //variable declarations
    int n,k,m,x;
    int dis;
    
    //Input file pointer declaration
    FILE *inputfilepointer;
    
    //File Opening for read
    char *inputfilename = argv[1];
    inputfilepointer    = fopen( inputfilename , "r");
    
    //Checking if file ptr is NULL
    if ( inputfilepointer == NULL )  {
        printf( "input.txt file failed to open." );
        return 0;
    }
    
    
    fscanf( inputfilepointer, "%d", &n );      //scaning for number of vehicles
    fscanf( inputfilepointer, "%d", &k );      //scaning for number of toll tax zones
    fscanf( inputfilepointer, "%d", &m );      //scaning for number of toll tax points
    fscanf( inputfilepointer, "%d", &x );      //scaning for toll tax zone passing time
    
    fscanf( inputfilepointer, "%d", &dis );    //scaning for distance between two consecutive toll tax zones


    // scanning for speeds of each vehicles for every subsequent toll tax combinations
    int *speed = (int *) malloc ( n*( k+1 ) * sizeof (int) );
    for ( int i=0; i<=k; i++ )  {
        for ( int j=0; j<n; j++ )  {
            fscanf( inputfilepointer, "%d", &speed[i*n+j] );
        }
    }
    
    // results is in the format of first crossing vehicles list, last crossing vehicles list 
    //               and total time taken by each vehicles to pass the highway
    int **results = (int **) malloc ( 3 * sizeof (int *) );
    results[0] = (int *) malloc ( (k+1) * sizeof (int) );
    results[1] = (int *) malloc ( (k+1) * sizeof (int) );
    results[2] = (int *) malloc ( (n) * sizeof (int) );


    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    float milliseconds = 0;
    cudaEventRecord(start,0);


    // Function given to implement
    operations ( n, k, m, x, dis, speed, results );


    cudaDeviceSynchronize();

    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&milliseconds, start, stop);
    printf("Time taken by function to execute is: %.6f ms\n", milliseconds);
    
    // Output file pointer declaration
    char *outputfilename = argv[2]; 
    FILE *outputfilepointer;
    outputfilepointer = fopen(outputfilename,"w");

    // First crossing vehicles list
    for ( int i=0; i<=k; i++ )  {
        fprintf( outputfilepointer, "%d ", results[0][i]);
    }
    fprintf( outputfilepointer, "\n");


    //Last crossing vehicles list
    for ( int i=0; i<=k; i++ )  {
        fprintf( outputfilepointer, "%d ", results[1][i]);
    }
    fprintf( outputfilepointer, "\n");


    //Total time taken by each vehicles to pass the highway
    for ( int i=0; i<n; i++ )  {
        fprintf( outputfilepointer, "%d ", results[2][i]);
    }
    fprintf( outputfilepointer, "\n");

    fclose( outputfilepointer );
    fclose( inputfilepointer );
    return 0;
}