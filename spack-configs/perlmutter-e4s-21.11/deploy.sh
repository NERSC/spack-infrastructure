#!/bin/bash
source $CI_PROJECT_DIR/setup-env.sh
e4s_root=/global/common/software/spackecp/perlmutter/e4s-21.11/$CI_PIPELINE_ID
spack_root=$e4s_root/spack
mkdir -p $e4s_root
cd $e4s_root
git clone https://github.com/spack/spack.git -b e4s-21.11 $spack_root
export SPACK_PYTHON=$(which python)
cd $spack_root
spack --version
spack-python --path
spack env create e4s $CI_PROJECT_DIR/spack-configs/perlmutter-e4s-21.11/spack.yaml
spack env activate e4s
spack env st
spack install -y --show-log-on-error
spack find

spack config get compilers > $SPACK_ROOT/etc/spack/compilers.yaml
spack config get packages > $SPACK_ROOT/etc/spack/packages.yaml
cp $CI_PROJECT_DIR/spack_site_scope/perlmutter/config.yaml $SPACK_ROOT/etc/spack/config.yaml
cp $CI_PROJECT_DIR/spack-configs/perlmutter-e4s-21.11/spack-setup.sh $SPACK_ROOT/bin/spack-setup.sh
cp $CI_PROJECT_DIR/spack-configs/perlmutter-e4s-21.11/spack-setup.csh $SPACK_ROOT/bin/spack-setup.csh
