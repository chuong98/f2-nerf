export PATH=$PATH:/usr/local/cuda-11.7/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-11.7/lib64
cmake . -B build
cmake --build build --target main --config RelWithDebInfo -j