#!/bin/bash
export SPACK_GNUPGHOME=$HOME/.gnupg

if [ $# -eq 0 ]
  then
    echo "No arguments supplied for mirror path. Please specify full path to spack mirror "
    exit 1
fi

E4S_MIRROR=$1
rm -rf $E4S_MIRROR
mkdir -p $E4S_MIRROR
spack gpg list
for ii in $(spack find --format "yyy {version} /{hash}" |
	    grep -v -E "^(develop^master)" |
	    grep "yyy" |
	    cut -f3 -d" ")
do
  spack buildcache create -af -d $E4S_MIRROR --only=package $ii
done

spack buildcache update-index -d $E4S_MIRROR -k

