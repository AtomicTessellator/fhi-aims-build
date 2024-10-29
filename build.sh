#!/bin/bash

# Set up Git SSH
export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

# Clone repository
git clone git@aims-git.rz-berlin.mpg.de:aims/FHIaims.git

# Set up environment
export CUDA_HOME=/usr/local/cuda
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64
export PATH=$PATH:$CUDA_HOME/bin

# Configure Git
git config --global --add safe.directory /workspaces/fhi-aims-build/FHIaims
git config --global --add safe.directory /workspaces/fhi-aims-build/FHIaims/external_libraries/elsi_interface

# Build
mkdir /workspaces/fhi-aims-build/FHIaims/build && \
cd /workspaces/fhi-aims-build/FHIaims/build && \
cp /workspaces/fhi-aims-build/initial_cache.cmake.gpu_all .

# Activate the Intel ONEAPI compilers
source /opt/intel/oneapi/setvars.sh

# Run cmake and build the binary
cmake -C initial_cache.cmake.gpu_all .. && \
make -j $(nproc)
