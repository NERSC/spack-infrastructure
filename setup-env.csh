#!/bin/tcsh

if (! $?CI_PROJECT_DIR) then

    # figure out a command to list open files (Linux)
    if (-d /proc/$$/fd) then
        set _open_fd = "ls -l /proc/$$/fd"
    endif

    # filter list of open files
    if ( $?_open_fd ) then
        set _source_file = `$_open_fd | sed -e 's/^[^/]*//' | grep "/setup-env.csh"`
    endif

    # setup-env.csh is located in spack infrastructure repo
    if ( $?_source_file ) then
        setenv CI_PROJECT_DIR `dirname "$_source_file"`
    endif
endif

set py_env_dir=$CI_PROJECT_DIR/spack-pyenv

# ensure we remove the python virtual environment before creating it. For some reason there is permission issues with activate.csh when in virtual environment
if (-d $py_env_dir) then
	rm -rf $py_env_dir
endif

python3 -m venv $py_env_dir
source $py_env_dir/bin/activate.csh
pip install clingo
which python && pip list
rm -rf ~/.spack/
setenv SPACK_DISABLE_LOCAL_CONFIG true
setenv SPACK_PYTHON `which python`
