#!/bin/bash
python3 -m venv $CI_PROJECT_DIR/spack-pyenv
source $CI_PROJECT_DIR/spack-pyenv/bin/activate
pip install clingo
which python && pip list
rm -rf ~/.spack/
export SPACK_DISABLE_LOCAL_CONFIG=true
cd $CI_PROJECT_DIR
systemlayer=/global/common/software/spackecp/perlmutter/systemlayer/
spack_root=$systemlayer/spack
rm -rf $systemlayer
mkdir -p $systemlayer
cd $systemlayer
git clone https://github.com/spack/spack.git -b  v0.17.1 $spack_root
export SPACK_PYTHON=$(which python)
. $spack_root/share/spack/setup-env.sh
spack --version
spack-python --path
spack env create systemlayer $CI_PROJECT_DIR/spack-configs/perlmutter-systemlayer/ci/spack.yaml
spack env activate systemlayer
spack env st
spack install
spack module tcl refresh --delete-tree -y
spack find
ml systemlayer
ml av
