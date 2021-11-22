#!/bin/bash
export SPACK_DISABLE_LOCAL_CONFIG=true
despactivate
spack env rm -y e4s
spack env create e4s  prod/spack.yaml
spack env activate e4s
spack install 
spack module lmod refresh --delete-tree -y
spack module tcl refresh --delete-tree -y
