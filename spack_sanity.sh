#!/bin/bash 

# check nvhpc compilers 
/opt/nvidia/hpc_sdk/Linux_x86_64/21.11/compilers/bin/nvc --version
/opt/nvidia/hpc_sdk/Linux_x86_64/21.11/compilers/bin/nvc+ --version
/opt/nvidia/hpc_sdk/Linux_x86_64/21.11/compilers/bin/nvfortran --version

# check cray compilers
/opt/cray/pe/craype/default/bin/cc --version
/opt/cray/pe/craype/default/bin/CC --version
/opt/cray/pe/craype/default/bin/ftn --version

# nvhpc compiler definition
module is-avail PrgEnv-nvhpc nvhpc/21.11 craype-x86-milan libfabric 
# gcc compiler definition
module is avail PrgEnv-gnu gcc/11.2.0 craype-x86-milan libfabric 

# cray compiler definition
module is-avail PrgEnv-cray cce/13.0.2 craype-x86-milan libfabric

# check cray-libsci
module is-avail cray-libsci/21.08.1.2

# check cray-mpich
ls -ld /opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1
ls -ld /opt/cray/pe/mpich/8.1.15/ofi/nvidia/20.7
ls -ld /opt/cray/pe/mpich/8.1.15/ofi/cray/10.0
module is-avail cray-mpich/8.1.15

# check cudatoolkit
ls -ld /opt/nvidia/hpc_sdk/Linux_x86_64/21.11/cuda/11.5
ls -ld /opt/nvidia/hpc_sdk/Linux_x86_64/21.11/math_libs/11.5
module is-avail cudatoolkit/11.5

# check libfabric
ls -ld /opt/cray/libfabric/1.11.0.4.114
module is-avail libfabric/1.11.0.4.114

# check cray-pmi
module is-avail cray-pmi/6.1.1
