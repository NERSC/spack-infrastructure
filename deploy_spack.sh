#!/bin/bash
spack_root=/global/common/software/spackecp/perlmutter/e4s-21.08/spack
rm -rf $spack_root
git clone git@github.com:spack/spack.git -b e4s-21.08 $spack_root
cd $spack_root
git cherry-pick  7dc0ca4
