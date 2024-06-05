FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04 as nvidia-base

RUN apt update
RUN apt install -y gpg-agent wget git cmake python3 python3-pip vim

# NVidia HPC Toolkit
RUN mkdir /nvhpc_2024_245_Linux_x86_64_cuda_12.4
ADD https://atomict-public.s3.us-west-2.amazonaws.com/nvhpc_2024_245_Linux_x86_64_cuda_12.4.tar.gz /nvhpc_2024_245_Linux_x86_64_cuda_12.4
RUN tar -xvf /nvhpc_2024_245_Linux_x86_64_cuda_12.4/nvhpc_2024_245_Linux_x86_64_cuda_12.4.tar.gz -C /nvhpc_2024_245_Linux_x86_64_cuda_12.4
RUN rm -rf nvhpc_2024_245_Linux_x86_64_cuda_12.4.tar.gz
RUN yes "" | /nvhpc_2024_245_Linux_x86_64_cuda_12.4/nvhpc_2024_245_Linux_x86_64_cuda_12.4/install --accept --silent

# NVidia HPC Environment
ENV PATH="/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/compilers/bin:/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/comm_libs/mpi/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/compilers/lib:/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/comm_libs/mpi/lib:${LD_LIBRARY_PATH}"

# Intel MKL
RUN wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list
RUN apt update
RUN apt install -y intel-oneapi-mkl intel-oneapi-mkl-devel intel-oneapi-mpi intel-hpckit libopenmpi-dev

# MKL Environment
ENV PATH="/opt/intel/oneapi/vtune/2024.1/bin64:/opt/intel/oneapi/mpi/2021.12/bin:/opt/intel/oneapi/mkl/2024.1/bin/:/opt/intel/oneapi/dpcpp-ct/2024.1/bin:/opt/intel/oneapi/dev-utilities/2024.1/bin:/opt/intel/oneapi/debugger/2024.1/opt/debugger/bin:/opt/intel/oneapi/compiler/2024.1/opt/oclfpga/bin:/opt/intel/oneapi/compiler/2024.1/bin:/opt/intel/oneapi/advisor/2024.1/bin64:${PATH}"
ENV LD_LIBRARY_PATH="/opt/intel/oneapi/mpi/latest/lib:/opt/intel/oneapi/tbb/2021.12/env/../lib/intel64/gcc4.8:/opt/intel/oneapi/mpi/2021.12/opt/mpi/libfabric/lib:/opt/intel/oneapi/mpi/2021.12/lib:/opt/intel/oneapi/mkl/2024.1/lib:/opt/intel/oneapi/ippcp/2021.11/lib/:/opt/intel/oneapi/ipp/2021.11/lib:/opt/intel/oneapi/dpl/2022.5/lib:/opt/intel/oneapi/dnnl/2024.1/lib:/opt/intel/oneapi/debugger/2024.1/opt/debugger/lib:/opt/intel/oneapi/dal/2024.2/lib:/opt/intel/oneapi/compiler/2024.1/opt/oclfpga/host/linux64/lib:/opt/intel/oneapi/compiler/2024.1/opt/compiler/lib:/opt/intel/oneapi/compiler/2024.1/lib:/opt/intel/oneapi/ccl/2021.12/lib/:${LD_LIBRARY_PATH}"
ENV CFLAGS="-I/usr/lib/x86_64-linux-gnu/openmpi/include/ $CFLAGS"

# CUDA 12.4
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
RUN mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
RUN wget https://atomict-public.s3.us-west-2.amazonaws.com/cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb
RUN dpkg -i cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb
RUN cp /var/cuda-repo-ubuntu2204-12-4-local/cuda-*-keyring.gpg /usr/share/keyrings/
RUN apt-get update
RUN apt-get -y install cuda-toolkit-12-4 pkg-config libcairo2-dev

# CUDA Environment
ENV CUDA_HOME="/usr/local/cuda"
ENV CFLAGS="-I$CUDA_HOME/targets/x86_64-linux/include $CFLAGS"
ENV LDFLAGS="-L$CUDA_HOME/lib64 $LDFLAGS"

# Launch
CMD ["bash"]
