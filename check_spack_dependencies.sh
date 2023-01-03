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
	nvhpc_versions=( 22.5)
	nvhpc_modules=( nvhpc/21.11 )
	cray_mpich_version=8.1.22
	cray_libsci_version=22.11.1.2
	libfabric_version=1.15.2.0
	cray_pmi_version=6.1.7
elif [ "$NERSC_HOST" == "muller" ]; then
	nvhpc_versions=( 21.11 22.5 22.7 22.9)
	nvhpc_modules=( nvhpc/21.11 nvhpc/22.5 nvhpc/22.7 nvhpc/22.9 )
	cray_mpich_version=8.1.22
	cray_libsci_version=22.11.1.2
	libfabric_version=1.15.2.0
	cray_pmi_version=6.1.7
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

# check cray-mpich
ls -ld /opt/cray/pe/mpich/$cray_mpich_version/ofi/gnu/9.1
ls -ld /opt/cray/pe/mpich/$cray_mpich_version/ofi/nvidia/20.7
ls -ld /opt/cray/pe/mpich/$cray_mpich_version/ofi/cray/10.0
module is-avail cray-mpich/$cray_mpich_version 2>1

# check libfabric
ls -ld /opt/cray/libfabric/$libfabric_version
module is-avail libfabric/$libfabric_version 2>1

# check cray-pmi
module is-avail cray-pmi/$cray_pmi_version 2>1

# check cudatoolkit
ls -ld /opt/nvidia/hpc_sdk/Linux_x86_64/21.11/cuda/11.5
ls -ld /opt/nvidia/hpc_sdk/Linux_x86_64/21.11/math_libs/11.5
module is-avail cudatoolkit/11.5 2>1

ls -ld /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/cuda/11.7
ls -ld /opt/nvidia/hpc_sdk/Linux_x86_64/22.5/math_libs/11.7
module is-avail cudatoolkit/11.7 2>1
