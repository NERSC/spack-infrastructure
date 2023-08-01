#!/bin/bash

if [ -z "$CI_PROJECT_DIR" ]; then
	CI_PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"
fi
python3 -m venv $CI_PROJECT_DIR/spack-pyenv
source $CI_PROJECT_DIR/spack-pyenv/bin/activate
pip install clingo  
which python && pip list 
export SPACK_DISABLE_LOCAL_CONFIG=true
export SPACK_PYTHON=$(which python)
