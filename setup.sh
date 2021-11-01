#!/bin/bash
spack_root=/global/common/software/spackecp/perlmutter/e4s-21.08/spack
source $spack_root/share/spack/setup-env.sh

repo_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"
spack env activate .
