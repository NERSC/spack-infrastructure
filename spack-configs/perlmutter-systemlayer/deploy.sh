#!/bin/bash
python3 -m venv $CI_PROJECT_DIR/spack-pyenv
source $CI_PROJECT_DIR/spack-pyenv/bin/activate
pip install clingo  
which python && pip list 
rm -rf ~/.spack/
export SPACK_DISABLE_LOCAL_CONFIG=true
cd $CI_PROJECT_DIR
systemlayer=/global/common/software/spackecp/perlmutter/systemlayer/
spack_root=/global/common/software/spackecp/perlmutter/systemlayer/spack
mkdir -p $systemlayer
rm -rf $spack_root
cd $systemlayer
git clone git@github.com:spack/spack.git -b  v0.17.1 $spack_root
export SPACK_PYTHON=$(which python)
. $spack_root/share/spack/setup-env.sh
spack --version
spack-python --path
spack env activate -d $CI_PROJECT_DIR/spack-configs/perlmutter-systemlayer/ci
spack install
spack module tcl refresh --delete-tree -y
