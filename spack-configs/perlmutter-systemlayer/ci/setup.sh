#!/bin/bash
python3 -m venv $CI_PROJECT_DIR/spack-pyenv
source $CI_PROJECT_DIR/spack-pyenv/bin/activate
pip install clingo  
which python && pip list 
rm -rf ~/.spack/
export SPACK_DISABLE_LOCAL_CONFIG=true
cd $CI_PROJECT_DIR
git clone https://github.com/spack/spack
cd spack
git checkout tags/0.17.1
. share/spack/setup-env.sh
spack-python --path
cd $CI_PROJECT_DIR

# need to set line below to cherry-pick commit
#git config user.name 'e4s' 
#git config user.email 'e4s@nersc.gov'
# NVHPC 21.11 - https://github.com/spack/spack/pull/27910
#git cherry-pick 5d6a9a7

spack env activate -d $CI_PROJECT_DIR/spack-configs/perlmutter-systemlayer/ci
