# fhi-aims-build

### How to build:
- Build the docker container (open in dev-containers in vscode)

#### Get FHI aims source code and decompress
(e.g. to fhi-aims.240507)

#### 3 - Make build dir
```
> cd fhi-aims.240507
> rm -rf build
> mkdir build && cd build
```

#### Copy the CPU or GPU makefile to the current directory
```
# initial_cache.cmake.cpu           CPU build
# initial_cache.cmake.gpu_all       GPU build (all gpu archs - longer build, larger binary, less performant runtime)
# initial_cache.cmake.gpu_sm86      GPU build for sm86 (e.g. RTX 3060) specific arch only
# Feel free to add more GPU specific builds!
```

#### Copy the build file we want
```
> cp ../../initial_cache.cmake.gpu_all .
```
#### Activate the Intel ONEAPI compilers

```
> source /opt/intel/oneapi/setvars.sh
```
#### Set your CUDA vars
```
> export CUDA_HOME=/usr/local/cuda
> export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64
> export PATH=$PATH:$CUDA_HOME/bin
```
#### Run cmake and build the binary
```
> cmake -C initial_cache.cmake.gpu ..
> make -j 12
```
