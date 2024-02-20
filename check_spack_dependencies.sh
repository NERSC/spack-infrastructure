#!/bin/bash

set -ve

#set NERSC_HOST if it's not already set
if [ -z "$NERSC_HOST" ]; then
    if [ -e /etc/clustername ]; then
        export NERSC_HOST=`cat /etc/clustername`
    fi
fi


# check nvhpc compilers

if [ "$NERSC_HOST" == "perlmutter" ]; then
	nvhpc_versions=( 22.7 23.1 23.9)
	nvhpc_modules=(nvhpc/22.7 nvhpc/23.1 nvhpc/23.9)
	cce_modules=( cce/15.0.1 cce/16.0.0 cce/17.0.0)
	gcc_modules=( gcc/11.2.0 gcc-native/12.3.0)
	cray_mpich_version=8.1.28
	cray_libsci_version=23.12.5
	libfabric_version=1.15.2.0
	cray_pmi_version=6.1.13
	

elif [ "$NERSC_HOST" == "muller" ]; then
	nvhpc_versions=( 22.7 23.1 23.9)
	nvhpc_modules=(  nvhpc/22.7 nvhpc/23.1 nvhpc/23.9)
	cce_modules=( cce/15.0.1 cce/16.0.0 cce/17.0.0)
	gcc_modules=( gcc/11.2.0 gcc-native/12.3.0 )
	cray_mpich_version=8.1.28
	cray_libsci_version=23.12.5
	libfabric_version=1.15.2.0
	cray_pmi_version=6.1.13
	
fi

for nvhpc_ver in "${nvhpc_versions[@]}"
do
	/opt/nvidia/hpc_sdk/Linux_x86_64/$nvhpc_ver/compilers/bin/nvc --version
	/opt/nvidia/hpc_sdk/Linux_x86_64/$nvhpc_ver/compilers/bin/nvc++ --version
	/opt/nvidia/hpc_sdk/Linux_x86_64/$nvhpc_ver/compilers/bin/nvfortran --version
done

# check cray compilers
/opt/cray/pe/craype/default/bin/cc --version
/opt/cray/pe/craype/default/bin/CC --version
/opt/cray/pe/craype/default/bin/ftn --version

for nvhpc_module in "${nvhpc_modules[@]}"
do
  # test nvhpc compiler definition
  module is-avail PrgEnv-nvhpc $nvhpc_module craype-x86-milan libfabric 2>1
done

for gcc_module in "${gcc_modules[@]}"
do
  # test gcc compiler definition
  module is-avail PrgEnv-gnu $gcc_module craype-x86-milan libfabric 2>1
done

for cce_module in "${cce_modules[@]}"
do
  # test cce compiler definition
  module is-avail PrgEnv-cray $cce_module craype-x86-milan libfabric 2>1
done

# check cray-libsci
module is-avail cray-libsci/$cray_libsci_version 2>1


# check cray-mpich 8.1.28
ls -ld /opt/cray/pe/mpich/$cray_mpich_version/ofi/gnu/12.3
ls -ld /opt/cray/pe/mpich/$cray_mpich_version/ofi/nvidia/23.3
ls -ld /opt/cray/pe/mpich/$cray_mpich_version/ofi/cray/17.0
module is-avail cray-mpich/$cray_mpich_version 2>1

# check libfabric
ls -ld /opt/cray/libfabric/$libfabric_version
module is-avail libfabric/$libfabric_version 2>1

# check cray-pmi
module is-avail cray-pmi/$cray_pmi_version 2>1

# check cudatoolkit
ls -ld  /opt/nvidia/hpc_sdk/Linux_x86_64/23.9/cuda/12.2
ls -ld /opt/nvidia/hpc_sdk/Linux_x86_64/23.9/cuda/12.2/targets/x86_64-linux
module is-avail cudatoolkit/12.2 2>1
