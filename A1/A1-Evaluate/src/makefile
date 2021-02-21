main: kernels.o main.o
	/usr/local/cuda/bin/nvcc kernels.o main.o -o main.out -Wno-deprecated-gpu-targets

kernels.o: kernels.cu kernels.h
	/usr/local/cuda/bin/nvcc -c kernels.cu -Wno-deprecated-gpu-targets

main.o: main.cu
	/usr/local/cuda/bin/nvcc -c main.cu -Wno-deprecated-gpu-targets

clean: 
	rm -rf *.o *.out 
	
remove: 
	rm -rf *.o *.out *.log *.h kernels.cu main.cu 
