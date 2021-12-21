#!/bin/bash
python3 -m venv $CI_PROJECT_DIR/spack-pyenv
source $CI_PROJECT_DIR/spack-pyenv/bin/activate
pip install clingo  
which python && pip list 
rm -rf ~/.spack/
export SPACK_DISABLE_LOCAL_CONFIG=true
git clone -b e4s-21.11 $SPACK_REPO
. spack/share/spack/setup-env.sh
cd $CI_PROJECT_DIR
spack-python --path
cd spack
# need to set line below to cherry-pick commit
git config user.name 'e4s' 
git config user.email 'e4s@nersc.gov'
# NVHPC 21.11 - https://github.com/spack/spack/pull/27910
git cherry-pick 5d6a9a7
spack env activate -d spack-configs/perlmutter-systemlayer/ci
