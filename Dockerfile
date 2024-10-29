# Base stage
FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04 as base

RUN apt update && apt install -y gpg-agent wget git cmake python3 python3-pip vim

# NVidia HPC Toolkit
RUN mkdir /nvhpc_2024_245_Linux_x86_64_cuda_12.4 && \
    wget -q -O - https://atomict-public.s3.us-west-2.amazonaws.com/nvhpc_2024_245_Linux_x86_64_cuda_12.4.tar.gz | tar -xvz -C /nvhpc_2024_245_Linux_x86_64_cuda_12.4 && \
    yes "" | /nvhpc_2024_245_Linux_x86_64_cuda_12.4/nvhpc_2024_245_Linux_x86_64_cuda_12.4/install --accept --silent && \
    rm -rf /nvhpc_2024_245_Linux_x86_64_cuda_12.4

# NVidia HPC Environment
ENV PATH="/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/compilers/bin:/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/comm_libs/mpi/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/compilers/lib:/opt/nvidia/hpc_sdk/Linux_x86_64/24.5/comm_libs/mpi/lib:${LD_LIBRARY_PATH}"

# Intel MKL
RUN wget -qO- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list && \
    apt update && \
    apt install -y intel-oneapi-mkl intel-oneapi-mkl-devel intel-oneapi-mpi intel-hpckit libopenmpi-dev

# MKL Environment
ENV PATH="/opt/intel/oneapi/vtune/2024.1/bin64:/opt/intel/oneapi/mpi/2021.12/bin:/opt/intel/oneapi/mkl/2024.1/bin/:/opt/intel/oneapi/dpcpp-ct/2024.1/bin:/opt/intel/oneapi/dev-utilities/2024.1/bin:/opt/intel/oneapi/debugger/2024.1/opt/debugger/bin:/opt/intel/oneapi/compiler/2024.1/opt/oclfpga/bin:/opt/intel/oneapi/compiler/2024.1/bin:/opt/intel/oneapi/advisor/2024.1/bin64:${PATH}" \
    LD_LIBRARY_PATH="/opt/intel/oneapi/mpi/latest/lib:/opt/intel/oneapi/tbb/2021.12/env/../lib/intel64/gcc4.8:/opt/intel/oneapi/mpi/2021.12/opt/mpi/libfabric/lib:/opt/intel/oneapi/mpi/2021.12/lib:/opt/intel/oneapi/mkl/2024.1/lib:/opt/intel/oneapi/ippcp/2021.11/lib/:/opt/intel/oneapi/ipp/2021.11/lib:/opt/intel/oneapi/dpl/2022.5/lib:/opt/intel/oneapi/dnnl/2024.1/lib:/opt/intel/oneapi/debugger/2024.1/opt/debugger/lib:/opt/intel/oneapi/dal/2024.2/lib:/opt/intel/oneapi/compiler/2024.1/opt/oclfpga/host/linux64/lib:/opt/intel/oneapi/compiler/2024.1/opt/compiler/lib:/opt/intel/oneapi/compiler/2024.1/lib:/opt/intel/oneapi/ccl/2021.12/lib/:${LD_LIBRARY_PATH}" \
    CFLAGS="-I/usr/lib/x86_64-linux-gnu/openmpi/include/ $CFLAGS"

# CUDA 12.4
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin && \
    mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
    wget https://atomict-public.s3.us-west-2.amazonaws.com/cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb && \
    dpkg -i cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb && \
    cp /var/cuda-repo-ubuntu2204-12-4-local/cuda-*-keyring.gpg /usr/share/keyrings/ && \
    apt-get update && \
    apt-get -y install cuda-toolkit-12-4 pkg-config libcairo2-dev && \
    rm cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb

# CUDA Environment
ENV CUDA_HOME="/usr/local/cuda" \
    CFLAGS="-I$CUDA_HOME/targets/x86_64-linux/include $CFLAGS" \
    LDFLAGS="-L$CUDA_HOME/lib64 $LDFLAGS"

# Auth container
FROM base as auth_container

# Install SSH client
RUN apt-get install -y openssh-client

# Set up SSH directory
RUN mkdir -p /root/.ssh \
    && chmod 700 /root/.ssh

# Set up Git to use SSH
RUN git config --global core.sshCommand "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

# Final stage
FROM auth_container as final

# Set working directory
WORKDIR /workspaces/fhi-aims-build

CMD ["/workspaces/fhi-aims-build/build.sh"]
