#!/bin/bash
spack_root=/global/common/software/spackecp/perlmutter/systemlayer/spack
rm -rf $spack_root
git clone git@github.com:spack/spack.git -b e4s-21.11 $spack_root
cd $spack_root
# NVHPC 21.11
git cherry-pick 5d6a9a7
