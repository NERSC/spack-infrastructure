#!/bin/bash
spack_root=/global/common/software/spackecp/perlmutter/e4s-21.11/spack
source $spack_root/share/spack/setup-env.sh
export SPACK_DISABLE_LOCAL_CONFIG=true
spack env deactivate
spack env rm -y e4s
spack env create e4s  spack.yaml
spack env activate e4s
spack install 
spack module lmod refresh --delete-tree -y
spack module tcl refresh --delete-tree -y
