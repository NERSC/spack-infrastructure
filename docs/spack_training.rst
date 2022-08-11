Spack Training
==============

Goal
-----

The goal of this training is to provide advice for how one can best use Spack to install packages and manage
a software stack on Perlmutter. We will cover several common topics, including configuring your Spack
environment, building variants and generating custom modulefiles. After completing the training, one
can expect to be familiar with the customizations needed for an optimal Spack experience on Perlmutter.

.. COMMENT: I suggest using Spack when talking about the software, and using formatting, i.e. ``spack`` when talking about
   commands.  -- Also, we can delete these comments


Pre-Requisite
--------------

In order to perform this training, you need a `NERSC account <https://docs.nersc.gov/accounts/>`_ and access to
`Perlmutter <https://docs.nersc.gov/systems/perlmutter/>`_. We assume you already have a basic understanding of
`spack <https://spack.readthedocs.io/en/latest/>`_.



Setup
-------

In order to get started, please `Connect to Perlmutter <https://docs.nersc.gov/connect/>`_ via **ssh**. Once you have access, please
clone the following repo in your $HOME directory.

.. code:: console

    git clone https://github.com/NERSC/spack-infrastructure.git

User Environment
-----------------

Spack builds can be sensitive to your user environment and any configuration setup in your `shell startup <https://docs.nersc.gov/environment/shell_startup/>`_,
we recommend you review your startup configuration files. Some things to look out for are the following:

1. Loading or unloading of any modules.
2. Activating a python or Conda environment.
3. Any user environment variables such as $PATH.

.. note::
   We have seen that purging modules (`module purge`) can alter Spack builds and cause most of the Cray programming environment
   to be removed. For more details see `spack/#27124 <https://github.com/spack/spack/issues/27124>`_.

When performing Spack builds, we encourage using the startup modules that are loaded by default. This should look at follows:

.. code-block:: console

    siddiq90@login34> module list

    Currently Loaded Modules:
      1) craype-x86-milan     4) perftools-base/22.06.0                 7) craype/2.7.16      10) cray-libsci/21.08.1.2  13) darshan/3.3.1 (io)
      2) libfabric/1.15.0.0   5) xpmem/2.3.2-2.2_7.5__g93dd7ee.shasta   8) cray-dsmml/0.2.2   11) PrgEnv-gnu/8.3.3
      3) craype-network-ofi   6) gcc/11.2.0                             9) cray-mpich/8.1.17  12) xalt/2.10.2

      Where:
       io:  Input/output software


In order to setup our environment, let's source the setup script which will create a clean python environment to perform our Spack builds. Please
run the following commands:

.. code-block:: console

    siddiq90@login34> cd spack-infrastructure/
    siddiq90@login34> source setup-env.sh
    Collecting clingo
      Using cached clingo-5.5.2-cp36-cp36m-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (2.2 MB)
    Collecting cffi
      Using cached cffi-1.15.1-cp36-cp36m-manylinux_2_5_x86_64.manylinux1_x86_64.whl (402 kB)
    Collecting pycparser
      Using cached pycparser-2.21-py2.py3-none-any.whl (118 kB)
    Installing collected packages: pycparser, cffi, clingo
    Successfully installed cffi-1.15.1 clingo-5.5.2 pycparser-2.21
    WARNING: You are using pip version 20.2.3; however, version 21.3.1 is available.
    You should consider upgrading via the '/global/homes/s/siddiq90/spack-infrastructure/spack-pyenv/bin/python3 -m pip install --upgrade pip' command.
    /global/homes/s/siddiq90/spack-infrastructure/spack-pyenv/bin/python
    Package    Version
    ---------- -------
    cffi       1.15.1
    clingo     5.5.2
    pip        20.2.3
    pycparser  2.21
    setuptools 44.1.1
    WARNING: You are using pip version 20.2.3; however, version 21.3.1 is available.
    You should consider upgrading via the '/global/homes/s/siddiq90/spack-infrastructure/spack-pyenv/bin/python3 -m pip install --upgrade pip' command.


The ``setup-env.sh`` script will install ``clingo`` in your python environment which is typically required by Spack along with a few
other configurations relevant for building Spack.

.. note::
   Spack requires clingo in-order to bootstrap clingo however we observed
   issues with Spack unable to bootstrap clingo see `spack/28315 <https://github.com/spack/spack/issues/28315>`_. We found that installing clingo
   as a python package addressed the issue.

.. COMMENT: Note that on the clingo website they don't capitalize "clingo".



Acquiring Spack
----------------

For this training we will clone the following Spack branch and source the setup script.

.. code-block:: console

    git clone -b e4s-22.05 https://github.com/spack/spack.git
    source spack/share/spack/setup-env.sh

Once you have acquired Spack and sourced the activation script, please run the following commands to ensure your setup is done correctly. We
have configured the environment, ``SPACK_PYTHON``, to use a python wrapper in the virtual environment.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack --version
    0.18.0.dev0 (6040c82740449632aa1d6faab08f93f5e4c54615)

    (spack-pyenv) siddiq90@login34> echo $SPACK_PYTHON
    /global/homes/s/siddiq90/spack-infrastructure/spack-pyenv/bin/python

    (spack-pyenv) siddiq90@login34> which python
    /global/homes/s/siddiq90/spack-infrastructure/spack-pyenv/bin/python

The command below will pass the full path to the python interpreter used by Spack, which should be the path
set by environment ``SPACK_PYTHON``.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack-python --path
    /global/homes/s/siddiq90/spack-infrastructure/spack-pyenv/bin/python


Creating a Spack Environment
-----------------------------

When using Spack, you may be tempted to start installing packages via **spack install** in your Spack instance. Note
that it's best you organize your Spack stacks in their own `spack environment <https://spack.readthedocs.io/en/latest/environments.html>`_,
similar to how one would organize a python or Conda environment.

Let's start by creating a Spack environment named `data_viz`, and activating it.

.. code-block:: console

    spack env create data_viz
    spack env activate data_viz

Upon completion you should confirm the output of **spack env status** matches the following:

.. COMMENT: Full command is probably more helpful when people are first learning

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack env st
    ==> In environment data_viz

Let's navigate to the directory for Spack environment **data_viz**. You will see a file **spack.yaml** that
is used to specify your Spack configuration. This includes configuration options such as which compilers
to use in your Spack builds.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack cd -e data_viz
    (spack-pyenv) siddiq90@login34> ls -l
    total 1
    -rw-rw-r-- 1 siddiq90 siddiq90 199 Aug  3 19:09 spack.yaml

Defining Compilers
--------------------

In order to use Spack, one must define a list of compilers in order to build packages. On Perlmutter, we have ``gcc/11.2.0``
and ``cce/13.0.2`` compilers available as modulefiles which correspond to the GCC and Cray compiler. In order to specify the
compiler definition we must use the corresponding ``PrgEnv-*`` module.

.. code-block::

    (spack-pyenv) siddiq90@login34> module load -t av gcc/11.2.0 cce/13.0.2
    /opt/cray/pe/lmod/modulefiles/core:
    cce/13.0.2
    gcc/11.2.0

.. COMMMET: Please confirm ml is the same as "module load"

Let's add the following content in `spack.yaml`. Please open the file in your preferred editor and paste the contents. Note that we
specify the full path for `cc`, `cxx`, `f77`, and `fc` which should correspond to the Cray wrappers.

.. code-block:: yaml
    :linenos:
    :emphasize-lines: 13-46

    # This is a Spack Environment file.
    #
    # It describes a set of packages to be installed, along with
    # configuration settings.
    spack:
      config:
        view: false
        concretization: separately
        build_stage: $spack/var/spack/stage
        misc_cache: $spack/var/spack/misc_cache
        concretizer: clingo

      compilers:
      - compiler:
          spec: gcc@11.2.0
          paths:
            cc: cc
            cxx: CC
            f77: ftn
            fc: ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-gnu
          - gcc/11.2.0
          - craype-x86-milan
          - libfabric
          extra_rpaths: []
      - compiler:
          spec: cce@13.0.2
          paths:
            cc: /opt/cray/pe/craype/default/bin/cc
            cxx: /opt/cray/pe/craype/default/bin/CC
            f77: /opt/cray/pe/craype/default/bin/ftn
            fc: /opt/cray/pe/craype/default/bin/ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-cray
          - cce/13.0.2
          - craype-x86-milan
          - libfabric
          environment: {}
          extra_rpaths: []

      # add package specs to the `specs` list
      specs: []
      packages:
        all:
          compiler: [gcc@11.2.0, cce@13.0.2]

      view: true

.. note::

    The directory `/opt/cray/pe/craype/default` resorts to the default Cray programming environment, ``craype``, in this case its 2.7.16 and
    the `cc` wrapper should be from this corresponding directory.

    .. code-block:: console

        (spack-pyenv) siddiq90@login34> ls -ld /opt/cray/pe/craype/default
        lrwxrwxrwx 1 root root 6 Jun  1 14:56 /opt/cray/pe/craype/default -> 2.7.16

        (spack-pyenv) siddiq90@login34> which cc
        /opt/cray/pe/craype/2.7.16/bin/cc

On Perlmutter, the `craype/2.7.16` modulefile is responsible for setting the Cray wrappers which is loaded by default
as shown below:

.. code-block:: console

    (spack-pyenv) siddiq90@login34> module load -t list craype/2.7.16
    craype/2.7.16

If this modulefile was removed, you will not have access to the Cray wrappers `cc`, `CC` or `ftn` which may result in
several errors.

Now let's check all available compilers by running ``spack compiler list``

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack compiler list
    ==> Available compilers
    -- cce sles15-any -----------------------------------------------
    cce@13.0.2

    -- gcc sles15-any -----------------------------------------------
    gcc@11.2.0


Package Preference
-------------------

Now let's try to run ``spack spec -Il hdf5``, you will notice Spack will try to install all the packages from source, some of which
are dependencies that should not be installed but rather set as `external packages <https://spack.readthedocs.io/en/latest/build_settings.html#external-packages>`_.
For instance, utilities like **openssl**, **bzip2**, **diffutils**, **openmpi**, **openssh** should not be installed from source. We have documented a
`Spack Externals Recommendation <https://github.com/NERSC/spack-infrastructure/blob/main/spack-externals.md>`_ that outlines a list
of packages where we recommend using the NERSC system installations.

.. code-block:: console
    :linenos:
    :emphasize-lines: 12,15,16,19,21,34,36

    (spack-pyenv) siddiq90@login34> spack spec -Il hdf5
    Input spec
    --------------------------------
     -   hdf5

    Concretized
    --------------------------------
     -   z4dfikd  hdf5@1.12.2%gcc@11.2.0~cxx~fortran~hl~ipo~java+mpi+shared~szip~threadsafe+tools api=default build_type=RelWithDebInfo arch=cray-sles15-zen3
     -   auepzq2      ^cmake@3.23.1%gcc@11.2.0~doc+ncurses+ownlibs~qt build_type=Release arch=cray-sles15-zen3
     -   2t22mc5          ^ncurses@6.2%gcc@11.2.0~symlinks+termlib abi=none arch=cray-sles15-zen3
     -   nugfov2              ^pkgconf@1.8.0%gcc@11.2.0 arch=cray-sles15-zen3
     -   i2r3jpl          ^openssl@1.1.1o%gcc@11.2.0~docs~shared certs=system arch=cray-sles15-zen3
     -   ekj3iat              ^perl@5.34.1%gcc@11.2.0+cpanm+shared+threads arch=cray-sles15-zen3
     -   hafeanv                  ^berkeley-db@18.1.40%gcc@11.2.0+cxx~docs+stl patches=b231fcc arch=cray-sles15-zen3
     -   blbwwl4                  ^bzip2@1.0.8%gcc@11.2.0~debug~pic+shared arch=cray-sles15-zen3
     -   gvbyw6w                      ^diffutils@3.8%gcc@11.2.0 arch=cray-sles15-zen3
     -   3xwztgy                          ^libiconv@1.16%gcc@11.2.0 libs=shared,static arch=cray-sles15-zen3
     -   bxrz7zm                  ^gdbm@1.19%gcc@11.2.0 arch=cray-sles15-zen3
     -   avhrefq                      ^readline@8.1%gcc@11.2.0 arch=cray-sles15-zen3
     -   ozmcyfj                  ^zlib@1.2.12%gcc@11.2.0+optimize+pic+shared patches=0d38234 arch=cray-sles15-zen3
     -   gdm5qma      ^openmpi@4.1.3%gcc@11.2.0~atomics~cuda~cxx~cxx_exceptions~gpfs~internal-hwloc~java~legacylaunchers~lustre~memchecker~pmi+pmix+romio+rsh~singularity+static+vt+wrapper-rpath fabrics=none schedulers=none arch=cray-sles15-zen3
     -   6rkjosk          ^hwloc@2.7.1%gcc@11.2.0~cairo~cuda~gl~libudev+libxml2~netloc~nvml~opencl+pci~rocm+shared arch=cray-sles15-zen3
     -   oyeiwvg              ^libpciaccess@0.16%gcc@11.2.0 arch=cray-sles15-zen3
     -   56oycjj                  ^libtool@2.4.7%gcc@11.2.0 arch=cray-sles15-zen3
     -   flsruli                      ^m4@1.4.19%gcc@11.2.0+sigsegv patches=9dc5fbd,bfdffa7 arch=cray-sles15-zen3
     -   wcuq435                          ^libsigsegv@2.13%gcc@11.2.0 arch=cray-sles15-zen3
     -   koitq65                  ^util-macros@1.19.3%gcc@11.2.0 arch=cray-sles15-zen3
     -   u2ai4xj              ^libxml2@2.9.13%gcc@11.2.0~python arch=cray-sles15-zen3
     -   tyswlp4                  ^xz@5.2.5%gcc@11.2.0~pic libs=shared,static arch=cray-sles15-zen3
     -   w2itznc          ^libevent@2.1.12%gcc@11.2.0+openssl arch=cray-sles15-zen3
     -   t4jyphv          ^numactl@2.0.14%gcc@11.2.0 patches=4e1d78c,62fc8a8,ff37630 arch=cray-sles15-zen3
     -   al4xc7v              ^autoconf@2.69%gcc@11.2.0 patches=35c4492,7793209,a49dd5b arch=cray-sles15-zen3
     -   2uxxcnx              ^automake@1.16.5%gcc@11.2.0 arch=cray-sles15-zen3
     -   w5aq2sc          ^openssh@9.0p1%gcc@11.2.0 arch=cray-sles15-zen3
     -   mkoju5b              ^libedit@3.1-20210216%gcc@11.2.0 arch=cray-sles15-zen3
     -   t3wpbom          ^pmix@4.1.2%gcc@11.2.0~docs+pmi_backwards_compatibility~restful arch=cray-sles15-zen3

Let's try to update our Spack configuration with the package externals as follows:

.. code-block:: yaml
    :linenos:
    :emphasize-lines: 53-97

    # This is a Spack Environment file.
    #
    # It describes a set of packages to be installed, along with
    # configuration settings.
    spack:
      config:
        view: false
        concretization: separately
        build_stage: $spack/var/spack/stage
        misc_cache: $spack/var/spack/misc_cache
        concretizer: clingo

      compilers:
      - compiler:
          spec: gcc@11.2.0
          paths:
            cc: cc
            cxx: CC
            f77: ftn
            fc: ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-gnu
          - gcc/11.2.0
          - craype-x86-milan
          - libfabric
          extra_rpaths: []
      - compiler:
          spec: cce@13.0.2
          paths:
            cc: /opt/cray/pe/craype/default/bin/cc
            cxx: /opt/cray/pe/craype/default/bin/CC
            f77: /opt/cray/pe/craype/default/bin/ftn
            fc: /opt/cray/pe/craype/default/bin/ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-cray
          - cce/13.0.2
          - craype-x86-milan
          - libfabric
          environment: {}
          extra_rpaths: []

      # add package specs to the `specs` list
      specs: []
      packages:
        all:
          compiler: [gcc@11.2.0, cce@13.0.2]
        bzip2:
          version: [1.0.6]
          externals:
          - spec: bzip2@1.0.6
            prefix: /usr
        diffutils:
          version: [3.6]
          externals:
          - spec: diffutils@3.6
            prefix: /usr
        findutils:
          version: [4.6.0]
          externals:
          - spec: findutils@4.6.0
            prefix: /usr
        openssl:
          version: [1.1.0i]
          buildable: false
          externals:
          - spec: openssl@1.1.0i
            prefix: /usr
        openssh:
          version: [7.9p1]
          buildable: false
          externals:
          - spec: openssh@7.9p1
            prefix: /usr
        readline:
          version: [7.0]
          buildable: false
          externals:
          - spec: readline@7.0
            prefix: /usr
        tar:
          version: [1.3]
          buildable: false
          externals:
          - spec: tar@1.30
            prefix: /usr
        unzip:
          version: [6.0]
          buildable: false
          externals:
          - spec: unzip@6.0
            prefix: /usr

      view: true

Many software packages depend on MPI, BLAS, PMI, and libfabrics, and these packages are typically available on Perlmutter. Shown below is a
breakdown of the provider and its corresponding modules typically available on Perlmutter

- MPI: cray-mpich
- BLAS: cray-libsci
- PMI: cray-pmi
- libfabrics: libfabrics

Shown below are the corresponding modules that you should consider when setting up external packages.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> ml -d av cray-mpich cray-libsci cray-pmi libfabrics

    --------------------------------------------------- Cray Compiler/Network Dependent Packages ----------------------------------------------------
       cray-mpich-abi/8.1.17    cray-mpich/8.1.17 (L)

    --------------------------------------------------------------- Cray Core Modules ---------------------------------------------------------------
       cray-libsci/21.08.1.2 (L)    cray-pmi-lib/6.0.17    cray-pmi/6.1.3

      Where:
       L:  Module is loaded

    Use "module spider" to find all possible modules and extensions.
    Use "module keyword key1 key2 ..." to search for all possible modules matching any of the "keys".

In Spack, you can use the ``spack providers`` command to find the corresponding Spack package that maps to the provider.
In Spack these are referred to as virtual packages which are a collection of Spack packages that provide the same functionality.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack providers
    Virtual packages:
        D     daal      flame  glu     iconv  jpeg     lua-lang        mkl  mysql-client  osmesa  pkgconfig  sycl  unwind  yacc
        awk   elf       fuse   glx     ipp    lapack   luajit          mpe  onedal        pbs     rpc        szip  uuid    ziglang
        blas  fftw-api  gl     golang  java   libllvm  mariadb-client  mpi  opencl        pil     scalapack  tbb   xxd

For instance, if you want to see all the MPI providers you can run the following. Note that ``cray-mpich`` is in the list.

.. COMMENT: when talking about code I suggest using `` `` -- I may have missed some of these before.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack providers mpi
    mpi:
    cray-mpich     intel-mpi              mpich@:1.1  mpich          mpt@1:         mvapich2@2.3:  openmpi         spectrum-mpi
    cray-mvapich2  intel-oneapi-mpi       mpich@:1.2  mpilander      mpt@3:         mvapich2-gdr   openmpi@1.6.5
    fujitsu-mpi    intel-parallel-studio  mpich@:3.1  mpitrampoline  mvapich2       mvapich2x      openmpi@1.7.5:
    hpcx-mpi       mpich@:1.0             mpich@:3.2  mpt            mvapich2@2.1:  nvhpc          openmpi@2.0.0:

Now let's try to update our Spack configuration as follows:

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 53-55, 61-85,96-103

    # This is a Spack Environment file.
    #
    # It describes a set of packages to be installed, along with
    # configuration settings.
    spack:
      config:
        view: false
        concretization: separately
        build_stage: $spack/var/spack/stage
        misc_cache: $spack/var/spack/misc_cache
        concretizer: clingo

      compilers:
      - compiler:
          spec: gcc@11.2.0
          paths:
            cc: cc
            cxx: CC
            f77: ftn
            fc: ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-gnu
          - gcc/11.2.0
          - craype-x86-milan
          - libfabric
          extra_rpaths: []
      - compiler:
          spec: cce@13.0.2
          paths:
            cc: /opt/cray/pe/craype/default/bin/cc
            cxx: /opt/cray/pe/craype/default/bin/CC
            f77: /opt/cray/pe/craype/default/bin/ftn
            fc: /opt/cray/pe/craype/default/bin/ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-cray
          - cce/13.0.2
          - craype-x86-milan
          - libfabric
          environment: {}
          extra_rpaths: []

      # add package specs to the `specs` list
      specs: []
      packages:
        all:
          compiler: [gcc@11.2.0, cce@13.0.2]
          providers:
            blas: [cray-libsci]
            mpi: [cray-mpich]
        bzip2:
          version: [1.0.6]
          externals:
          - spec: bzip2@1.0.6
            prefix: /usr
        cray-libsci:
          buildable: false
          externals:
          - spec: cray-libsci@21.08.1.2
            modules:
            - cray-libsci/21.08.1.2
        cray-mpich:
          buildable: false
          externals:
          - spec: cray-mpich@8.1.15 %gcc@11.2.0
            prefix: /opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1
            modules:
            - cray-mpich/8.1.15
            - cudatoolkit/11.5
          - spec: cray-mpich@8.1.15 %cce@13.0.2
            prefix: /opt/cray/pe/mpich/8.1.15/ofi/cray/10.0/
            modules:
            - cray-mpich/8.1.15
            - cudatoolkit/11.5
        cray-pmi:
          buildable: false
          externals:
          - spec: cray-pmi@6.1.1
            modules:
            - cray-pmi/6.1.1
        diffutils:
          version: [3.6]
          externals:
          - spec: diffutils@3.6
            prefix: /usr
        findutils:
          version: [4.6.0]
          externals:
          - spec: findutils@4.6.0
            prefix: /usr
        libfabric:
          buildable: false
          variants: fabrics=sockets,tcp,udp,rxm
          externals:
          - spec: libfabric@1.11.0.4.114
            prefix: /opt/cray/libfabric/1.11.0.4.114
            modules:
            - libfabric/1.11.0.4.114
        openssl:
          version: [1.1.0i]
          buildable: false
          externals:
          - spec: openssl@1.1.0i
            prefix: /usr
        openssh:
          version: [7.9p1]
          buildable: false
          externals:
          - spec: openssh@7.9p1
            prefix: /usr
        readline:
          version: [7.0]
          buildable: false
          externals:
          - spec: readline@7.0
            prefix: /usr
        tar:
          version: [1.3]
          buildable: false
          externals:
          - spec: tar@1.30
            prefix: /usr
        unzip:
          version: [6.0]
          buildable: false
          externals:
          - spec: unzip@6.0
            prefix: /usr

      view: true

Let's try to run ``spack spec hypre`` and notice that Spack will now use ``cray-libsci`` and ``cray-mpich`` as the dependencies,
because we have set these packages as externals.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack spec hypre
    Input spec
    --------------------------------
    hypre@2.24.0

    Concretized
    --------------------------------
    hypre@2.24.0%gcc@11.2.0~complex~cuda~debug+fortran~gptune~int64~internal-superlu~mixedint+mpi~openmp~rocm+shared~superlu-dist~unified-memory arch=cray-sles15-zen3
        ^cray-libsci@21.08.1.2%gcc@11.2.0~mpi~openmp+shared arch=cray-sles15-zen3
        ^cray-mpich@8.1.15%gcc@11.2.0+wrappers arch=cray-sles15-zen3

Now let's try to add some packages to our Spack configuration by adding the following lines:

.. code-block:: yaml
    :linenos:
    :emphasize-lines: 48-53

    # This is a Spack Environment file.
    #
    # It describes a set of packages to be installed, along with
    # configuration settings.
    spack:
      config:
        view: false
        concretization: separately
        build_stage: $spack/var/spack/stage
        misc_cache: $spack/var/spack/misc_cache
        concretizer: clingo
      compilers:
      - compiler:
          spec: gcc@11.2.0
          paths:
            cc: cc
            cxx: CC
            f77: ftn
            fc: ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-gnu
          - gcc/11.2.0
          - craype-x86-milan
          - libfabric
          extra_rpaths: []
      - compiler:
          spec: cce@13.0.2
          paths:
            cc: /opt/cray/pe/craype/default/bin/cc
            cxx: /opt/cray/pe/craype/default/bin/CC
            f77: /opt/cray/pe/craype/default/bin/ftn
            fc: /opt/cray/pe/craype/default/bin/ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-cray
          - cce/13.0.2
          - craype-x86-milan
          - libfabric
          environment: {}
          extra_rpaths: []
      # add package specs to the `specs` list
      specs:
      - papi %gcc
      - papi %cce
      - hypre %gcc
      - hypre %cce
      - darshan-runtime %gcc
      - darshan-runtime %cce
      packages:
        all:
          compiler: [gcc@11.2.0, cce@13.0.2]
          providers:
            blas: [cray-libsci]
            mpi: [cray-mpich]
        bzip2:
          version: [1.0.6]
          externals:
          - spec: bzip2@1.0.6
            prefix: /usr
        cray-libsci:
          buildable: false
          externals:
          - spec: cray-libsci@21.08.1.2
            modules:
            - cray-libsci/21.08.1.2
        cray-mpich:
          buildable: false
          externals:
          - spec: cray-mpich@8.1.15 %gcc@11.2.0
            prefix: /opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1
            modules:
            - cray-mpich/8.1.15
            - cudatoolkit/11.5
          - spec: cray-mpich@8.1.15 %cce@13.0.2
            prefix: /opt/cray/pe/mpich/8.1.15/ofi/cray/10.0/
            modules:
            - cray-mpich/8.1.15
            - cudatoolkit/11.5
        cray-pmi:
          buildable: false
          externals:
          - spec: cray-pmi@6.1.1
            modules:
            - cray-pmi/6.1.1
        diffutils:
          version: [3.6]
          externals:
          - spec: diffutils@3.6
            prefix: /usr
        findutils:
          version: [4.6.0]
          externals:
          - spec: findutils@4.6.0
            prefix: /usr
        libfabric:
          buildable: false
          variants: fabrics=sockets,tcp,udp,rxm
          externals:
          - spec: libfabric@1.11.0.4.114
            prefix: /opt/cray/libfabric/1.11.0.4.114
            modules:
            - libfabric/1.11.0.4.114
        openssl:
          version: [1.1.0i]
          buildable: false
          externals:
          - spec: openssl@1.1.0i
            prefix: /usr
        openssh:
          version: [7.9p1]
          buildable: false
          externals:
          - spec: openssh@7.9p1
            prefix: /usr
        readline:
          version: [7.0]
          buildable: false
          externals:
          - spec: readline@7.0
            prefix: /usr
        tar:
          version: [1.3]
          buildable: false
          externals:
          - spec: tar@1.30
            prefix: /usr
        unzip:
          version: [6.0]
          buildable: false
          externals:
          - spec: unzip@6.0
            prefix: /usr
      view: true

Next, we will concretize the environment, you should see ``papi``, ``hypre`` and ``darshan-runtime`` built with each compiler.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack concretize
    ==> Starting concretization pool with 6 processes
    ==> Environment concretized in 18.58 seconds.
    ==> Concretized papi%gcc
     -   s2y4nrv  papi@6.0.0.1%gcc@11.2.0~cuda+example~infiniband~lmsensors~nvml~powercap~rapl~rocm~rocm_smi~sde+shared~static_tools arch=cray-sles15-zen3

    ==> Concretized papi%cce
     -   3aprcx5  papi@6.0.0.1%cce@13.0.2~cuda+example~infiniband~lmsensors~nvml~powercap~rapl~rocm~rocm_smi~sde+shared~static_tools patches=b6d6caa arch=cray-sles15-zen3

    ==> Concretized hypre%gcc
     -   mbn7bum  hypre@2.24.0%gcc@11.2.0~complex~cuda~debug+fortran~gptune~int64~internal-superlu~mixedint+mpi~openmp~rocm+shared~superlu-dist~unified-memory arch=cray-sles15-zen3
     -   jzbnd6y      ^cray-libsci@21.08.1.2%gcc@11.2.0~mpi~openmp+shared arch=cray-sles15-zen3
     -   3zy6uvs      ^cray-mpich@8.1.15%gcc@11.2.0+wrappers arch=cray-sles15-zen3

    ==> Concretized hypre%cce
     -   62ofdsf  hypre@2.24.0%cce@13.0.2~complex~cuda~debug+fortran~gptune~int64~internal-superlu~mixedint+mpi~openmp~rocm+shared~superlu-dist~unified-memory arch=cray-sles15-zen3
     -   7uzhxpv      ^cray-libsci@21.08.1.2%cce@13.0.2~mpi~openmp+shared arch=cray-sles15-zen3
     -   tb5uxwe      ^cray-mpich@8.1.15%cce@13.0.2+wrappers arch=cray-sles15-zen3

    ==> Concretized darshan-runtime%gcc
     -   hkxzwvt  darshan-runtime@3.3.1%gcc@11.2.0~apmpi~apmpi_sync~apxc~hdf5+mpi scheduler=NONE arch=cray-sles15-zen3
     -   3zy6uvs      ^cray-mpich@8.1.15%gcc@11.2.0+wrappers arch=cray-sles15-zen3
     -   ozmcyfj      ^zlib@1.2.12%gcc@11.2.0+optimize+pic+shared patches=0d38234 arch=cray-sles15-zen3

    ==> Concretized darshan-runtime%cce
     -   uj3wa4a  darshan-runtime@3.3.1%cce@13.0.2~apmpi~apmpi_sync~apxc~hdf5+mpi scheduler=NONE arch=cray-sles15-zen3
     -   tb5uxwe      ^cray-mpich@8.1.15%cce@13.0.2+wrappers arch=cray-sles15-zen3
     -   e2hl6cx      ^zlib@1.2.12%cce@13.0.2+optimize+pic+shared patches=0d38234 arch=cray-sles15-zen3

Let's install all the packages via ``spack install``. This would be a good time to get a cup of coffee since it will likely
take a few minutes.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack install
    ==> Installing environment data_viz
    ==> Installing papi-6.0.0.1-s2y4nrvu6whr6hhgi63aa3nqwz2d35af
    ==> No binary for papi-6.0.0.1-s2y4nrvu6whr6hhgi63aa3nqwz2d35af found: installing from source
    ==> Fetching https://mirror.spack.io/_source-cache/archive/3c/3cd7ed50c65b0d21d66e46d0ba34cd171178af4bbf9d94e693915c1aca1e287f.tar.gz
    ==> No patches needed for papi
    ==> papi: Executing phase: 'autoreconf'
    ==> papi: Executing phase: 'configure'
    ==> papi: Executing phase: 'build'
    ==> papi: Executing phase: 'install'
    ==> papi: Successfully installed papi-6.0.0.1-s2y4nrvu6whr6hhgi63aa3nqwz2d35af
      Fetch: 1.49s.  Build: 28.94s.  Total: 30.43s.
    [+] /global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/gcc-11.2.0/papi-6.0.0.1-s2y4nrvu6whr6hhgi63aa3nqwz2d35af
    ==> Installing papi-6.0.0.1-3aprcx5klzafe7xt6aq57jx5sequpue2
    ==> No binary for papi-6.0.0.1-3aprcx5klzafe7xt6aq57jx5sequpue2 found: installing from source
    ==> Using cached archive: /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/cache/_source-cache/archive/3c/3cd7ed50c65b0d21d66e46d0ba34cd171178af4bbf9d94e693915c1aca1e287f.tar.gz
    ==> Applied patch /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/repos/builtin/packages/papi/crayftn-fixes.patch
    ==> papi: Executing phase: 'autoreconf'
    ==> papi: Executing phase: 'configure'
    ==> papi: Executing phase: 'build'
    ==> papi: Executing phase: 'install'
    ==> papi: Successfully installed papi-6.0.0.1-3aprcx5klzafe7xt6aq57jx5sequpue2
      Fetch: 0.01s.  Build: 28.94s.  Total: 28.95s.
    [+] /global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/cce-13.0.2/papi-6.0.0.1-3aprcx5klzafe7xt6aq57jx5sequpue2
    ==> cray-libsci@21.08.1.2 : has external module in ['cray-libsci/21.08.1.2']
    [+] /opt/cray/pe/libsci/21.08.1.2/GNU/9.1/x86_64 (external cray-libsci-21.08.1.2-jzbnd6ycupy2ycs5jiavwyvkxv3rpuru)
    ==> cray-mpich@8.1.15 : has external module in ['cray-mpich/8.1.15', 'cudatoolkit/11.5']
    [+] /opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1 (external cray-mpich-8.1.15-3zy6uvszbd5a3rniq2xd2v5a3d27qstw)
    ==> cray-libsci@21.08.1.2 : has external module in ['cray-libsci/21.08.1.2']
    [+] /opt/cray/pe/libsci/21.08.1.2/CRAY/9.0/x86_64 (external cray-libsci-21.08.1.2-7uzhxpvoka7ixfxs44354dkishquwyhq)
    ==> cray-mpich@8.1.15 : has external module in ['cray-mpich/8.1.15', 'cudatoolkit/11.5']
    [+] /opt/cray/pe/mpich/8.1.15/ofi/cray/10.0/ (external cray-mpich-8.1.15-tb5uxwezfzx4xth7azefyrhzlvf7koqb)
    ==> Installing zlib-1.2.12-ozmcyfjfv7i5gjjgklfsh43h67vzsuc5
    ==> No binary for zlib-1.2.12-ozmcyfjfv7i5gjjgklfsh43h67vzsuc5 found: installing from source
    ==> Fetching https://mirror.spack.io/_source-cache/archive/91/91844808532e5ce316b3c010929493c0244f3d37593afd6de04f71821d5136d9.tar.gz
    ==> Applied patch /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/repos/builtin/packages/zlib/configure-cc.patch
    ==> zlib: Executing phase: 'install'
    ==> zlib: Successfully installed zlib-1.2.12-ozmcyfjfv7i5gjjgklfsh43h67vzsuc5
      Fetch: 0.62s.  Build: 2.10s.  Total: 2.72s.
    [+] /global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/gcc-11.2.0/zlib-1.2.12-ozmcyfjfv7i5gjjgklfsh43h67vzsuc5
    ==> Installing zlib-1.2.12-e2hl6cxmzbg5psoh5upqmqqltjftc3pb
    ==> No binary for zlib-1.2.12-e2hl6cxmzbg5psoh5upqmqqltjftc3pb found: installing from source
    ==> Using cached archive: /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/cache/_source-cache/archive/91/91844808532e5ce316b3c010929493c0244f3d37593afd6de04f71821d5136d9.tar.gz
    ==> Applied patch /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/repos/builtin/packages/zlib/configure-cc.patch
    ==> zlib: Executing phase: 'install'
    ==> zlib: Successfully installed zlib-1.2.12-e2hl6cxmzbg5psoh5upqmqqltjftc3pb
      Fetch: 0.00s.  Build: 2.45s.  Total: 2.45s.
    [+] /global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/cce-13.0.2/zlib-1.2.12-e2hl6cxmzbg5psoh5upqmqqltjftc3pb
    ==> Installing hypre-2.24.0-mbn7bumcoqmjhf5y2sm3hnr64vml4dvf
    ==> No binary for hypre-2.24.0-mbn7bumcoqmjhf5y2sm3hnr64vml4dvf found: installing from source
    ==> Fetching https://mirror.spack.io/_source-cache/archive/f4/f480e61fc25bf533fc201fdf79ec440be79bb8117650627d1f25151e8be2fdb5.tar.gz
    ==> No patches needed for hypre
    ==> hypre: Executing phase: 'autoreconf'
    ==> hypre: Executing phase: 'configure'
    ==> hypre: Executing phase: 'build'
    ==> hypre: Executing phase: 'install'
    ==> hypre: Successfully installed hypre-2.24.0-mbn7bumcoqmjhf5y2sm3hnr64vml4dvf
      Fetch: 0.77s.  Build: 37.43s.  Total: 38.20s.
    [+] /global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/gcc-11.2.0/hypre-2.24.0-mbn7bumcoqmjhf5y2sm3hnr64vml4dvf
    ==> Installing hypre-2.24.0-62ofdsfxckay53ewpiidg4nlamhnzq3b
    ==> No binary for hypre-2.24.0-62ofdsfxckay53ewpiidg4nlamhnzq3b found: installing from source
    ==> Using cached archive: /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/cache/_source-cache/archive/f4/f480e61fc25bf533fc201fdf79ec440be79bb8117650627d1f25151e8be2fdb5.tar.gz
    ==> No patches needed for hypre
    ==> hypre: Executing phase: 'autoreconf'
    ==> hypre: Executing phase: 'configure'
    ==> hypre: Executing phase: 'build'
    ==> hypre: Executing phase: 'install'
    ==> hypre: Successfully installed hypre-2.24.0-62ofdsfxckay53ewpiidg4nlamhnzq3b
      Fetch: 0.01s.  Build: 1m 5.86s.  Total: 1m 5.87s.
    [+] /global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/cce-13.0.2/hypre-2.24.0-62ofdsfxckay53ewpiidg4nlamhnzq3b
    ==> Installing darshan-runtime-3.3.1-hkxzwvtw5rlmsvwt4irwnxxuwzwbuzoj
    ==> No binary for darshan-runtime-3.3.1-hkxzwvtw5rlmsvwt4irwnxxuwzwbuzoj found: installing from source
    ==> Fetching https://mirror.spack.io/_source-cache/archive/28/281d871335977d0592a49d053df93d68ce1840f6fdec27fea7a59586a84395f7.tar.gz
    ==> No patches needed for darshan-runtime
    ==> darshan-runtime: Executing phase: 'autoreconf'
    ==> darshan-runtime: Executing phase: 'configure'
    ==> darshan-runtime: Executing phase: 'build'
    ==> darshan-runtime: Executing phase: 'install'
    ==> darshan-runtime: Successfully installed darshan-runtime-3.3.1-hkxzwvtw5rlmsvwt4irwnxxuwzwbuzoj
      Fetch: 1.07s.  Build: 9.24s.  Total: 10.31s.
    [+] /global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/gcc-11.2.0/darshan-runtime-3.3.1-hkxzwvtw5rlmsvwt4irwnxxuwzwbuzoj
    ==> Installing darshan-runtime-3.3.1-uj3wa4au7kphj52syka4w3dxiadosagh
    ==> No binary for darshan-runtime-3.3.1-uj3wa4au7kphj52syka4w3dxiadosagh found: installing from source
    ==> Using cached archive: /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/cache/_source-cache/archive/28/281d871335977d0592a49d053df93d68ce1840f6fdec27fea7a59586a84395f7.tar.gz
    ==> No patches needed for darshan-runtime
    ==> darshan-runtime: Executing phase: 'autoreconf'
    ==> darshan-runtime: Executing phase: 'configure'
    ==> darshan-runtime: Executing phase: 'build'
    ==> darshan-runtime: Executing phase: 'install'
    ==> darshan-runtime: Successfully installed darshan-runtime-3.3.1-uj3wa4au7kphj52syka4w3dxiadosagh
      Fetch: 0.01s.  Build: 9.58s.  Total: 9.58s.
    [+] /global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/cce-13.0.2/darshan-runtime-3.3.1-uj3wa4au7kphj52syka4w3dxiadosagh
    ==> Updating view at /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/environments/data_viz/.spack-env/view
    ==> Warning: Skipping external package: cray-libsci@21.08.1.2%gcc@11.2.0~mpi~openmp+shared arch=cray-sles15-zen3/jzbnd6y
    ==> Warning: Skipping external package: cray-mpich@8.1.15%gcc@11.2.0+wrappers arch=cray-sles15-zen3/3zy6uvs
    ==> Warning: Skipping external package: cray-libsci@21.08.1.2%cce@13.0.2~mpi~openmp+shared arch=cray-sles15-zen3/7uzhxpv
    ==> Warning: Skipping external package: cray-mpich@8.1.15%cce@13.0.2+wrappers arch=cray-sles15-zen3/tb5uxwe
    ==> Error: 178 fatal error(s) when merging prefixes:
        `/global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/gcc-11.2.0/papi-6.0.0.1-s2y4nrvu6whr6hhgi63aa3nqwz2d35af/.spack/archived-files/src/removed_la_files.txt` and `/global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/cce-13.0.2/papi-6.0.0.1-3aprcx5klzafe7xt6aq57jx5sequpue2/.spack/archived-files/src/removed_la_files.txt` both project to `.spack/papi/archived-files/src/removed_la_files.txt`
        `/global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/gcc-11.2.0/papi-6.0.0.1-s2y4nrvu6whr6hhgi63aa3nqwz2d35af/.spack/install_environment.json` and `/global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/cce-13.0.2/papi-6.0.0.1-3aprcx5klzafe7xt6aq57jx5sequpue2/.spack/install_environment.json` both project to `.spack/papi/install_environment.json`
        `/global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/gcc-11.2.0/papi-6.0.0.1-s2y4nrvu6whr6hhgi63aa3nqwz2d35af/.spack/install_manifest.json` and `/global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/cce-13.0.2/papi-6.0.0.1-3aprcx5klzafe7xt6aq57jx5sequpue2/.spack/install_manifest.json` both project to `.spack/papi/install_manifest.json`

Upon completion you can run ``spack find`` to see all installed packages.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack find
    ==> In environment data_viz
    ==> Root specs
    -- no arch / cce ------------------------------------------------
    darshan-runtime%cce  hypre%cce  papi%cce

    -- no arch / gcc ------------------------------------------------
    darshan-runtime%gcc  hypre%gcc  papi%gcc

    ==> 12 installed packages
    -- cray-sles15-zen3 / cce@13.0.2 --------------------------------
    cray-libsci@21.08.1.2  cray-mpich@8.1.15  darshan-runtime@3.3.1  hypre@2.24.0  papi@6.0.0.1  zlib@1.2.12

    -- cray-sles15-zen3 / gcc@11.2.0 --------------------------------
    cray-libsci@21.08.1.2  cray-mpich@8.1.15  darshan-runtime@3.3.1  hypre@2.24.0  papi@6.0.0.1  zlib@1.2.12

Defining a Source Mirror
-------------------------

You may have noticed Spack will fetch tarballs from the web when installing packages and this can be time-consuming when downloading
large tarballs. It is a good idea to store tarballs on the filesystem once and then let Spack use them for any Spack builds. You should have
one location where tarballs. Let's run the following command:

.. COMMENT Maybe we should add, "It is a good idea if you have lots of disc space, ..."

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack mirror create -d $CI_PROJECT_DIR/spack_mirror -a
    ==> Adding package cray-libsci@21.08.1.2 to mirror
    ==> Adding package cray-libsci@21.08.1.2 to mirror
    ==> Adding package cray-mpich@8.1.15 to mirror
    ==> Adding package cray-mpich@8.1.15 to mirror
    ==> Adding package darshan-runtime@3.3.1 to mirror
    ==> Using cached archive: /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/cache/_source-cache/archive/28/281d871335977d0592a49d053df93d68ce1840f6fdec27fea7a59586a84395f7.tar.gz
    ==> Adding package darshan-runtime@3.3.1 to mirror
    ==> Adding package hypre@2.24.0 to mirror
    ==> Using cached archive: /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/cache/_source-cache/archive/f4/f480e61fc25bf533fc201fdf79ec440be79bb8117650627d1f25151e8be2fdb5.tar.gz
    ==> Adding package hypre@2.24.0 to mirror
    ==> Adding package papi@6.0.0.1 to mirror
    ==> Using cached archive: /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/cache/_source-cache/archive/3c/3cd7ed50c65b0d21d66e46d0ba34cd171178af4bbf9d94e693915c1aca1e287f.tar.gz
    ==> Fetching https://mirror.spack.io/_source-cache/archive/64/64c57b3ad4026255238cc495df6abfacc41de391a0af497c27d0ac819444a1f8
    ==> Adding package papi@6.0.0.1 to mirror
    ==> Adding package zlib@1.2.12 to mirror
    ==> Using cached archive: /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/cache/_source-cache/archive/91/91844808532e5ce316b3c010929493c0244f3d37593afd6de04f71821d5136d9.tar.gz
    ==> Adding package zlib@1.2.12 to mirror
    ==> Successfully created mirror in file:///global/homes/s/siddiq90/spack-infrastructure/spack_mirror
      Archive stats:
        4    already present
        4    added
        0    failed to fetch.

If you inspect the directory you will notice the tarballs are present in this directory.


.. code-block:: console

    (spack-pyenv) siddiq90@login34> ls -l $CI_PROJECT_DIR/spack_mirror/*
    /global/homes/s/siddiq90/spack-infrastructure/spack_mirror/darshan-runtime:
    total 1
    lrwxrwxrwx 1 siddiq90 siddiq90 99 Aug  4 08:28 darshan-runtime-3.3.1.tar.gz -> ../_source-cache/archive/28/281d871335977d0592a49d053df93d68ce1840f6fdec27fea7a59586a84395f7.tar.gz

    /global/homes/s/siddiq90/spack-infrastructure/spack_mirror/hypre:
    total 1
    lrwxrwxrwx 1 siddiq90 siddiq90 99 Aug  4 08:28 hypre-2.24.0.tar.gz -> ../_source-cache/archive/f4/f480e61fc25bf533fc201fdf79ec440be79bb8117650627d1f25151e8be2fdb5.tar.gz

    /global/homes/s/siddiq90/spack-infrastructure/spack_mirror/papi:
    total 2
    lrwxrwxrwx 1 siddiq90 siddiq90 99 Aug  4 08:28 papi-6.0.0.1.tar.gz -> ../_source-cache/archive/3c/3cd7ed50c65b0d21d66e46d0ba34cd171178af4bbf9d94e693915c1aca1e287f.tar.gz
    lrwxrwxrwx 1 siddiq90 siddiq90 92 Aug  4 08:28 raw-64c57b3 -> ../_source-cache/archive/64/64c57b3ad4026255238cc495df6abfacc41de391a0af497c27d0ac819444a1f8

    /global/homes/s/siddiq90/spack-infrastructure/spack_mirror/_source-cache:
    total 1
    drwxrwxr-x 7 siddiq90 siddiq90 512 Aug  4 08:28 archive

    /global/homes/s/siddiq90/spack-infrastructure/spack_mirror/zlib:
    total 1
    lrwxrwxrwx 1 siddiq90 siddiq90 99 Aug  4 08:28 zlib-1.2.12.tar.gz -> ../_source-cache/archive/91/91844808532e5ce316b3c010929493c0244f3d37593afd6de04f71821d5136d9.tar.gz

Building CUDA Packages
------------------------

On Perlmutter, the standalone CUDA package is available by loading the following  modulefile:

.. code-block:: console

    (spack-pyenv) siddiq90@login34> module load -t av cudatoolkit
    /opt/cray/pe/lmod/modulefiles/core:
    cudatoolkit/11.5
    cudatoolkit/11.7

NVIDIA provides CUDA as part of the NVHPC compiler which is installed on Perlmutter and accessible via `nvhpc` modulefile

.. COMMENT: This line is an example of how I suggest it should be done

.. code-block:: console

    (spack-pyenv) siddiq90@login34> module load -t av nvhpc
    /opt/cray/pe/lmod/modulefiles/mix_compilers:
    nvhpc-mixed/21.11
    nvhpc-mixed/22.5
    /opt/cray/pe/lmod/modulefiles/core:
    nvhpc/21.11
    nvhpc/22.5

The root of ``nvhpc/21.11`` is available at ``/opt/nvidia/hpc_sdk/Linux_x86_64/21.11``. You can see content of this modulefile by running
``module show nvhpc/21.11`` and inspecting the modulefile. Shown below is the directory structure for root of NVHPC stack.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> ls -l /opt/nvidia/hpc_sdk/Linux_x86_64/21.11
    total 0
    drwxr-xr-x  2 root root  72 Aug  1 07:03 cmake
    drwxrwxr-x  6 root root 144 Aug  1 07:07 comm_libs
    drwxrwxr-x 14 root root 235 Aug  1 07:07 compilers
    drwxrwxr-x  3 root root  78 Aug  1 07:07 cuda
    drwxrwxr-x 11 root root 205 Aug  1 07:05 examples
    drwxrwxr-x  3 root root  55 Aug  1 07:07 math_libs
    drwxrwxr-x  4 root root  71 Aug  1 07:07 profilers
    drwxrwxr-x  6 root root  90 Aug  1 07:03 REDIST

``cuda/11.5`` is installed in following directory, which can be activated by loading the ``cudatoolkit/11.5`` modulefile.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> ls -l /opt/nvidia/hpc_sdk/Linux_x86_64/21.11/cuda/11.5
    total 65
    drwxrwxr-x 3 root root   335 Aug  1 07:04 bin
    drwxrwxr-x 4 root root   385 Aug  1 07:04 compute-sanitizer
    -rw-r--r-- 1 root root   160 Dec  8  2021 DOCS
    -rw-r--r-- 1 root root 61727 Dec  8  2021 EULA.txt
    drwxrwxr-x 4 root root    44 Aug  1 07:04 extras
    lrwxrwxrwx 1 root root    28 Dec  8  2021 include -> targets/x86_64-linux/include
    lrwxrwxrwx 1 root root    24 Dec  8  2021 lib64 -> targets/x86_64-linux/lib
    drwxrwxr-x 7 root root   242 Aug  1 07:04 libnvvp
    drwxrwxr-x 3 root root    30 Aug  1 07:04 nvml
    drwxrwxr-x 7 root root   106 Aug  1 07:04 nvvm
    drwxrwxr-x 7 root root    94 Aug  1 07:04 nvvm-prev
    -rw-r--r-- 1 root root   524 Dec  8  2021 README
    drwxrwxr-x 3 root root    26 Aug  1 07:04 share
    drwxrwxr-x 3 root root    35 Aug  1 07:04 targets
    drwxrwxr-x 2 root root    52 Aug  1 07:05 tools
    -rw-r--r-- 1 root root  2669 Dec  8  2021 version.json

We can confirm the ``nvcc`` compiler provided by CUDA is available in this directory along with the ``libcudart.so`` (CUDA Runtime) library

.. code-block:: console

    (spack-pyenv) siddiq90@login34> /opt/nvidia/hpc_sdk/Linux_x86_64/21.11/cuda/11.5/bin/nvcc --version
    nvcc: NVIDIA (R) Cuda compiler driver
    Copyright (c) 2005-2021 NVIDIA Corporation
    Built on Thu_Nov_18_09:45:30_PST_2021
    Cuda compilation tools, release 11.5, V11.5.119
    Build cuda_11.5.r11.5/compiler.30672275_0

    (spack-pyenv) siddiq90@login34> ls /opt/nvidia/hpc_sdk/Linux_x86_64/21.11/cuda/11.5/lib64/libcudart.so
    /opt/nvidia/hpc_sdk/Linux_x86_64/21.11/cuda/11.5/lib64/libcudart.so

Let's define our CUDA package preference in our Spack configuration. To
illustrate, we will install ``papi`` with the spec ``papi +cuda %gcc``.
This indicates that we want PAPI installed with CUDA support using the GCC compiler.
Please copy the following content in your ``spack.yaml``.

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 55,92-99

    # This is a Spack Environment file.
    #
    # It describes a set of packages to be installed, along with
    # configuration settings.
    spack:
      config:
        view: false
        concretization: separately
        build_stage: $spack/var/spack/stage
        misc_cache: $spack/var/spack/misc_cache
        concretizer: clingo
      compilers:
      - compiler:
          spec: gcc@11.2.0
          paths:
            cc: cc
            cxx: CC
            f77: ftn
            fc: ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-gnu
          - gcc/11.2.0
          - craype-x86-milan
          - libfabric
          extra_rpaths: []
      - compiler:
          spec: cce@13.0.2
          paths:
            cc: /opt/cray/pe/craype/default/bin/cc
            cxx: /opt/cray/pe/craype/default/bin/CC
            f77: /opt/cray/pe/craype/default/bin/ftn
            fc: /opt/cray/pe/craype/default/bin/ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-cray
          - cce/13.0.2
          - craype-x86-milan
          - libfabric
          environment: {}
          extra_rpaths: []

      # add package specs to the `specs` list
      specs:
      - papi %gcc
      - papi %cce
      - hypre %gcc
      - hypre %cce
      - darshan-runtime %gcc
      - darshan-runtime %cce
      - papi +cuda %gcc
      packages:
        all:
          compiler: [gcc@11.2.0, cce@13.0.2]
          providers:
            blas: [cray-libsci]
            mpi: [cray-mpich]
        bzip2:
          version: [1.0.6]
          externals:
          - spec: bzip2@1.0.6
            prefix: /usr
        cray-libsci:
          buildable: false
          externals:
          - spec: cray-libsci@21.08.1.2
            modules:
            - cray-libsci/21.08.1.2
        cray-mpich:
          buildable: false
          externals:
          - spec: cray-mpich@8.1.15 %gcc@11.2.0
            prefix: /opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1
            modules:
            - cray-mpich/8.1.15
            - cudatoolkit/11.5
          - spec: cray-mpich@8.1.15 %cce@13.0.2
            prefix: /opt/cray/pe/mpich/8.1.15/ofi/cray/10.0/
            modules:
            - cray-mpich/8.1.15
            - cudatoolkit/11.5
        cray-pmi:
          buildable: false
          externals:
          - spec: cray-pmi@6.1.1
            modules:
            - cray-pmi/6.1.1
        cuda:
          buildable: false
          version: [11.5.0]
          externals:
          - spec: cuda@11.5.0
            prefix: /opt/nvidia/hpc_sdk/Linux_x86_64/21.11/cuda/11.5
            modules:
            - cudatoolkit/11.5
        diffutils:
          version: [3.6]
          externals:
          - spec: diffutils@3.6
            prefix: /usr
        findutils:
          version: [4.6.0]
          externals:
          - spec: findutils@4.6.0
            prefix: /usr
        libfabric:
          buildable: false
          variants: fabrics=sockets,tcp,udp,rxm
          externals:
          - spec: libfabric@1.11.0.4.114
            prefix: /opt/cray/libfabric/1.11.0.4.114
            modules:
            - libfabric/1.11.0.4.114
        openssl:
          version: [1.1.0i]
          buildable: false
          externals:
          - spec: openssl@1.1.0i
            prefix: /usr
        openssh:
          version: [7.9p1]
          buildable: false
          externals:
          - spec: openssh@7.9p1
            prefix: /usr
        readline:
          version: [7.0]
          buildable: false
          externals:
          - spec: readline@7.0
            prefix: /usr
        tar:
          version: [1.3]
          buildable: false
          externals:
          - spec: tar@1.30
            prefix: /usr
        unzip:
          version: [6.0]
          buildable: false
          externals:
          - spec: unzip@6.0
            prefix: /usr
      view: true

Now let's try to install.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack install
    ==> Installing environment data_viz
    ==> cuda@11.5.0 : has external module in ['cudatoolkit/11.5']
    [+] /opt/nvidia/hpc_sdk/Linux_x86_64/21.11/cuda/11.5 (external cuda-11.5.0-puekfe32hbj72iftffa3etecesmlqwqg)
    ==> Installing papi-6.0.0.1-x43djbqgyb64susljh3vu4czlqapbyie
    ==> No binary for papi-6.0.0.1-x43djbqgyb64susljh3vu4czlqapbyie found: installing from source
    ==> Using cached archive: /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/cache/_source-cache/archive/3c/3cd7ed50c65b0d21d66e46d0ba34cd171178af4bbf9d94e693915c1aca1e287f.tar.gz
    ==> No patches needed for papi
    ==> papi: Executing phase: 'autoreconf'
    ==> papi: Executing phase: 'configure'
    ==> papi: Executing phase: 'build'
    ==> papi: Executing phase: 'install'
    ==> papi: Successfully installed papi-6.0.0.1-x43djbqgyb64susljh3vu4czlqapbyie
      Fetch: 0.01s.  Build: 4m 46.76s.  Total: 4m 46.76s.
    [+] /global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/gcc-11.2.0/papi-6.0.0.1-x43djbqgyb64susljh3vu4czlqapbyie
    ==> Updating view at /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/environments/data_viz/.spack-env/view
    ==> Warning: Skipping external package: cray-libsci@21.08.1.2%gcc@11.2.0~mpi~openmp+shared arch=cray-sles15-zen3/jzbnd6y
    ==> Warning: Skipping external package: cray-mpich@8.1.15%gcc@11.2.0+wrappers arch=cray-sles15-zen3/3zy6uvs
    ==> Warning: Skipping external package: cray-libsci@21.08.1.2%cce@13.0.2~mpi~openmp+shared arch=cray-sles15-zen3/7uzhxpv
    ==> Warning: Skipping external package: cray-mpich@8.1.15%cce@13.0.2+wrappers arch=cray-sles15-zen3/tb5uxwe
    ==> Warning: Skipping external package: cuda@11.5.0%gcc@11.2.0~allow-unsupported-compilers~dev arch=cray-sles15-zen3/puekfe3
    ==> Error: 193 fatal error(s) when merging prefixes:
        `/global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/gcc-11.2.0/papi-6.0.0.1-s2y4nrvu6whr6hhgi63aa3nqwz2d35af/.spack/archived-files/src/removed_la_files.txt` and `/global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/cce-13.0.2/papi-6.0.0.1-3aprcx5klzafe7xt6aq57jx5sequpue2/.spack/archived-files/src/removed_la_files.txt` both project to `.spack/papi/archived-files/src/removed_la_files.txt`
        `/global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/gcc-11.2.0/papi-6.0.0.1-s2y4nrvu6whr6hhgi63aa3nqwz2d35af/.spack/install_environment.json` and `/global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/cce-13.0.2/papi-6.0.0.1-3aprcx5klzafe7xt6aq57jx5sequpue2/.spack/install_environment.json` both project to `.spack/papi/install_environment.json`
        `/global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/gcc-11.2.0/papi-6.0.0.1-s2y4nrvu6whr6hhgi63aa3nqwz2d35af/.spack/install_manifest.json` and `/global/u1/s/siddiq90/spack-infrastructure/spack/opt/spack/cray-sles15-zen3/cce-13.0.2/papi-6.0.0.1-3aprcx5klzafe7xt6aq57jx5sequpue2/.spack/install_manifest.json` both project to `.spack/papi/install_manifest.json`

Generating Modulefiles
-----------------------

In this section we let Spack generate modulefiles for the Spack packages we installed. Perlmutter is using Lmod as the module system which supports both
``tcl`` and ``lua`` modules. You may want to refer to `Modules <https://spack.readthedocs.io/en/latest/module_file_support.html>`_ for more information.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> module --version

    Modules based on Lua: Version 8.3.1  2020-02-16 19:46 :z
        by Robert McLay mclay@tacc.utexas.edu

For this training we will cover how to generate ``tcl`` modules in a flat hierarchy. To get started, let's add the following
to our Spack configuration:

.. code-block:: yaml
    :linenos:
    :emphasize-lines: 148-164

    # This is a Spack Environment file.
    #
    # It describes a set of packages to be installed, along with
    # configuration settings.
    spack:
      config:
        view: false
        concretization: separately
        build_stage: $spack/var/spack/stage
        misc_cache: $spack/var/spack/misc_cache
        concretizer: clingo
      compilers:
      - compiler:
          spec: gcc@11.2.0
          paths:
            cc: cc
            cxx: CC
            f77: ftn
            fc: ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-gnu
          - gcc/11.2.0
          - craype-x86-milan
          - libfabric
          extra_rpaths: []
      - compiler:
          spec: cce@13.0.2
          paths:
            cc: /opt/cray/pe/craype/default/bin/cc
            cxx: /opt/cray/pe/craype/default/bin/CC
            f77: /opt/cray/pe/craype/default/bin/ftn
            fc: /opt/cray/pe/craype/default/bin/ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-cray
          - cce/13.0.2
          - craype-x86-milan
          - libfabric
          environment: {}
          extra_rpaths: []

      # add package specs to the `specs` list
      specs:
      - papi %gcc
      - papi %cce
      - hypre %gcc
      - hypre %cce
      - darshan-runtime %gcc
      - darshan-runtime %cce
      - papi +cuda %gcc
      packages:
        all:
          compiler: [gcc@11.2.0, cce@13.0.2]
          providers:
            blas: [cray-libsci]
            mpi: [cray-mpich]
        bzip2:
          version: [1.0.6]
          externals:
          - spec: bzip2@1.0.6
            prefix: /usr
        cray-libsci:
          buildable: false
          externals:
          - spec: cray-libsci@21.08.1.2
            modules:
            - cray-libsci/21.08.1.2
        cray-mpich:
          buildable: false
          externals:
          - spec: cray-mpich@8.1.15 %gcc@11.2.0
            prefix: /opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1
            modules:
            - cray-mpich/8.1.15
            - cudatoolkit/11.5
          - spec: cray-mpich@8.1.15 %cce@13.0.2
            prefix: /opt/cray/pe/mpich/8.1.15/ofi/cray/10.0/
            modules:
            - cray-mpich/8.1.15
            - cudatoolkit/11.5
        cray-pmi:
          buildable: false
          externals:
          - spec: cray-pmi@6.1.1
            modules:
            - cray-pmi/6.1.1
        cuda:
          buildable: false
          version: [11.5.0]
          externals:
          - spec: cuda@11.5.0
            prefix: /opt/nvidia/hpc_sdk/Linux_x86_64/21.11/cuda/11.5
            modules:
            - cudatoolkit/11.5
        diffutils:
          version: [3.6]
          externals:
          - spec: diffutils@3.6
            prefix: /usr
        findutils:
          version: [4.6.0]
          externals:
          - spec: findutils@4.6.0
            prefix: /usr
        libfabric:
          buildable: false
          variants: fabrics=sockets,tcp,udp,rxm
          externals:
          - spec: libfabric@1.11.0.4.114
            prefix: /opt/cray/libfabric/1.11.0.4.114
            modules:
            - libfabric/1.11.0.4.114
        openssl:
          version: [1.1.0i]
          buildable: false
          externals:
          - spec: openssl@1.1.0i
            prefix: /usr
        openssh:
          version: [7.9p1]
          buildable: false
          externals:
          - spec: openssh@7.9p1
            prefix: /usr
        readline:
          version: [7.0]
          buildable: false
          externals:
          - spec: readline@7.0
            prefix: /usr
        tar:
          version: [1.3]
          buildable: false
          externals:
          - spec: tar@1.30
            prefix: /usr
        unzip:
          version: [6.0]
          buildable: false
          externals:
          - spec: unzip@6.0
            prefix: /usr
      modules:
        default:
          enable:
          - tcl
          tcl:
            blacklist_implicits: true
            hash_length: 0
            naming_scheme: '{name}/{version}-{compiler.name}-{compiler.version}'
            all:
              autoload: direct
              conflict:
              - '{name}'
              environment:
                set:
                  '{name}_ROOT': '{prefix}'
              suffixes:
                ^cuda: cuda

      view: true

The ``blacklist_implicits: true`` will ignore module generation for dependencies which is useful when you are building a large
software stack, you don't want an explosion of modulefiles for utilities that you would never use. The ``hash_length: 0`` will
avoid adding hash characters at end of modulefile, the ``naming_scheme`` will instruct Spack how to format the modulefiles
being written on the file-system. Now let's generate the modulefiles. It is generally a good idea to run this in debug mode to understand how
files are being generated. The ``spack module tcl refresh`` command will generate ``tcl`` modules, it is good idea to specify ``--delete-tree -y``
which will delete the root of module tree and ``-y`` will accept confirmation. In the output take note of where modulefiles are being written. You
will see a list of specs as ``BLACKLISTED_AS_IMPLICIT`` which are specs that will not generate modulefiles

.. code-block:: console
    :linenos:
    :emphasize-lines: 13-19,21

    (spack-pyenv) siddiq90@login34> spack -d module tcl refresh --delete-tree -y
    ==> [2022-08-04-09:42:35.558437] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/etc/spack/defaults/config.yaml
    ==> [2022-08-04-09:42:35.708144] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/environments/data_viz/spack.yaml
    ==> [2022-08-04-09:42:35.767338] Using environment 'data_viz'
    ==> [2022-08-04-09:42:35.968497] Imported module from built-in commands
    ==> [2022-08-04-09:42:35.975354] Imported module from built-in commands
    ==> [2022-08-04-09:42:35.991742] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/etc/spack/defaults/bootstrap.yaml
    ==> [2022-08-04-09:42:36.044748] DATABASE LOCK TIMEOUT: 3s
    ==> [2022-08-04-09:42:36.044959] PACKAGE LOCK TIMEOUT: No timeout
    ==> [2022-08-04-09:42:36.161175] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/etc/spack/defaults/repos.yaml
    ==> [2022-08-04-09:42:36.634555] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/etc/spack/defaults/modules.yaml
    ==> [2022-08-04-09:42:36.691668] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/etc/spack/defaults/cray/modules.yaml
    ==> [2022-08-04-09:42:38.077573] 	BLACKLISTED_AS_IMPLICIT : cray-libsci@21.08.1.2%cce@13.0.2~mpi~openmp+shared arch=cray-sles15-zen3/7uzhxpv
    ==> [2022-08-04-09:42:38.079387] 	BLACKLISTED_AS_IMPLICIT : cray-libsci@21.08.1.2%gcc@11.2.0~mpi~openmp+shared arch=cray-sles15-zen3/jzbnd6y
    ==> [2022-08-04-09:42:38.081189] 	BLACKLISTED_AS_IMPLICIT : cray-mpich@8.1.15%cce@13.0.2+wrappers arch=cray-sles15-zen3/tb5uxwe
    ==> [2022-08-04-09:42:38.082661] 	BLACKLISTED_AS_IMPLICIT : cray-mpich@8.1.15%gcc@11.2.0+wrappers arch=cray-sles15-zen3/3zy6uvs
    ==> [2022-08-04-09:42:38.084601] 	BLACKLISTED_AS_IMPLICIT : cuda@11.5.0%gcc@11.2.0~allow-unsupported-compilers~dev arch=cray-sles15-zen3/puekfe3
    ==> [2022-08-04-09:42:38.097284] 	BLACKLISTED_AS_IMPLICIT : zlib@1.2.12%cce@13.0.2+optimize+pic+shared patches=0d38234 arch=cray-sles15-zen3/e2hl6cx
    ==> [2022-08-04-09:42:38.099494] 	BLACKLISTED_AS_IMPLICIT : zlib@1.2.12%gcc@11.2.0+optimize+pic+shared patches=0d38234 arch=cray-sles15-zen3/ozmcyfj
    ==> [2022-08-04-09:44:22.697989] Regenerating tcl module files
    ==> [2022-08-04-09:44:22.872234] 	WRITE: darshan-runtime@3.3.1%cce@13.0.2~apmpi~apmpi_sync~apxc~hdf5+mpi scheduler=NONE arch=cray-sles15-zen3/uj3wa4a [/global/u1/s/siddiq90/spack-infrastructure/spack/share/spack/modules/cray-sles15-zen3/darshan-runtime/3.3.1-cce-13.0.2]
    ==> [2022-08-04-09:44:23.696894] Module name: cce/13.0.2
    ==> [2022-08-04-09:44:23.697138] Package directory variable prefix: CCE
    ==> [2022-08-04-09:44:23.959854] Module name: cce/13.0.2
    ==> [2022-08-04-09:44:23.960027] Package directory variable prefix: CCE
    ==> [2022-08-04-09:44:24.183730] Module name: cce/13.0.2
    ==> [2022-08-04-09:44:24.183920] Package directory variable prefix: CCE
    ==> [2022-08-04-09:44:24.810258] Module name: cce/13.0.2
    ==> [2022-08-04-09:44:24.810473] Package directory variable prefix: CCE
    ==> [2022-08-04-09:44:25.037930] Module name: cce/13.0.2
    ==> [2022-08-04-09:44:25.038163] Package directory variable prefix: CCE
    ==> [2022-08-04-09:44:25.052737] 	BLACKLISTED_AS_IMPLICIT : cray-mpich@8.1.15%cce@13.0.2+wrappers arch=cray-sles15-zen3/tb5uxwe
    ==> [2022-08-04-09:44:25.056012] 	BLACKLISTED_AS_IMPLICIT : zlib@1.2.12%cce@13.0.2+optimize+pic+shared patches=0d38234 arch=cray-sles15-zen3/e2hl6cx
    ==> [2022-08-04-09:44:25.060927] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/etc/spack/defaults/packages.yaml
    ==> [2022-08-04-09:44:25.113314] 	WRITE: darshan-runtime@3.3.1%gcc@11.2.0~apmpi~apmpi_sync~apxc~hdf5+mpi scheduler=NONE arch=cray-sles15-zen3/hkxzwvt [/global/u1/s/siddiq90/spack-infrastructure/spack/share/spack/modules/cray-sles15-zen3/darshan-runtime/3.3.1-gcc-11.2.0]
    ==> [2022-08-04-09:44:25.219719] 	BLACKLISTED_AS_IMPLICIT : cray-mpich@8.1.15%gcc@11.2.0+wrappers arch=cray-sles15-zen3/3zy6uvs
    ==> [2022-08-04-09:44:25.222960] 	BLACKLISTED_AS_IMPLICIT : zlib@1.2.12%gcc@11.2.0+optimize+pic+shared patches=0d38234 arch=cray-sles15-zen3/ozmcyfj
    ==> [2022-08-04-09:44:25.258546] 	WRITE: hypre@2.24.0%cce@13.0.2~complex~cuda~debug+fortran~gptune~int64~internal-superlu~mixedint+mpi~openmp~rocm+shared~superlu-dist~unified-memory arch=cray-sles15-zen3/62ofdsf [/global/u1/s/siddiq90/spack-infrastructure/spack/share/spack/modules/cray-sles15-zen3/hypre/2.24.0-cce-13.0.2]
    ==> [2022-08-04-09:44:25.550468] Module name: cce/13.0.2
    ==> [2022-08-04-09:44:25.550681] Package directory variable prefix: CCE
    ==> [2022-08-04-09:44:25.785678] Module name: cce/13.0.2
    ==> [2022-08-04-09:44:25.785853] Package directory variable prefix: CCE
    ==> [2022-08-04-09:44:25.995944] Module name: cce/13.0.2
    ==> [2022-08-04-09:44:25.996162] Package directory variable prefix: CCE
    ==> [2022-08-04-09:44:26.212011] Module name: cce/13.0.2
    ==> [2022-08-04-09:44:26.212283] Package directory variable prefix: CCE
    ==> [2022-08-04-09:44:26.225681] 	BLACKLISTED_AS_IMPLICIT : cray-libsci@21.08.1.2%cce@13.0.2~mpi~openmp+shared arch=cray-sles15-zen3/7uzhxpv
    ==> [2022-08-04-09:44:26.230079] 	BLACKLISTED_AS_IMPLICIT : cray-mpich@8.1.15%cce@13.0.2+wrappers arch=cray-sles15-zen3/tb5uxwe
    ==> [2022-08-04-09:44:26.238876] 	WRITE: hypre@2.24.0%gcc@11.2.0~complex~cuda~debug+fortran~gptune~int64~internal-superlu~mixedint+mpi~openmp~rocm+shared~superlu-dist~unified-memory arch=cray-sles15-zen3/mbn7bum [/global/u1/s/siddiq90/spack-infrastructure/spack/share/spack/modules/cray-sles15-zen3/hypre/2.24.0-gcc-11.2.0]
    ==> [2022-08-04-09:44:26.385208] 	BLACKLISTED_AS_IMPLICIT : cray-libsci@21.08.1.2%gcc@11.2.0~mpi~openmp+shared arch=cray-sles15-zen3/jzbnd6y
    ==> [2022-08-04-09:44:26.388329] 	BLACKLISTED_AS_IMPLICIT : cray-mpich@8.1.15%gcc@11.2.0+wrappers arch=cray-sles15-zen3/3zy6uvs
    ==> [2022-08-04-09:44:26.398423] 	WRITE: papi@6.0.0.1%cce@13.0.2~cuda+example~infiniband~lmsensors~nvml~powercap~rapl~rocm~rocm_smi~sde+shared~static_tools patches=b6d6caa arch=cray-sles15-zen3/3aprcx5 [/global/u1/s/siddiq90/spack-infrastructure/spack/share/spack/modules/cray-sles15-zen3/papi/6.0.0.1-cce-13.0.2]
    ==> [2022-08-04-09:44:26.749919] Module name: cce/13.0.2
    ==> [2022-08-04-09:44:26.750092] Package directory variable prefix: CCE
    ==> [2022-08-04-09:44:26.762459] 	WRITE: papi@6.0.0.1%gcc@11.2.0~cuda+example~infiniband~lmsensors~nvml~powercap~rapl~rocm~rocm_smi~sde+shared~static_tools arch=cray-sles15-zen3/s2y4nrv [/global/u1/s/siddiq90/spack-infrastructure/spack/share/spack/modules/cray-sles15-zen3/papi/6.0.0.1-gcc-11.2.0]
    ==> [2022-08-04-09:44:26.897249] 	WRITE: papi@6.0.0.1%gcc@11.2.0+cuda+example~infiniband~lmsensors~nvml~powercap~rapl~rocm~rocm_smi~sde+shared~static_tools arch=cray-sles15-zen3/x43djbq [/global/u1/s/siddiq90/spack-infrastructure/spack/share/spack/modules/cray-sles15-zen3/papi/6.0.0.1-gcc-11.2.0-cuda]
    ==> [2022-08-04-09:44:27.240985] Module name: gcc/11.2.0
    ==> [2022-08-04-09:44:27.241199] Package directory variable prefix: GCC
    ==> [2022-08-04-09:44:27.316093] 	BLACKLISTED_AS_IMPLICIT : cuda@11.5.0%gcc@11.2.0~allow-unsupported-compilers~dev arch=cray-sles15-zen3/puekfe3

Spack will generate the modulefiles in the following directory:

.. COMMENT: I am not sure of the meaning before

.. code-block:: console

    (spack-pyenv) siddiq90@login34> ls $SPACK_ROOT/share/spack/modules/$(spack arch)/*
    /global/homes/s/siddiq90/spack-infrastructure/spack/share/spack/modules/cray-sles15-zen3/darshan-runtime:
    3.3.1-cce-13.0.2  3.3.1-gcc-11.2.0

    /global/homes/s/siddiq90/spack-infrastructure/spack/share/spack/modules/cray-sles15-zen3/hypre:
    2.24.0-cce-13.0.2  2.24.0-gcc-11.2.0

    /global/homes/s/siddiq90/spack-infrastructure/spack/share/spack/modules/cray-sles15-zen3/papi:
    6.0.0.1-cce-13.0.2  6.0.0.1-gcc-11.2.0  6.0.0.1-gcc-11.2.0-cuda

Let's change the directory path such that modulefiles are not inside Spack's root directory and they are easy to remember. For this
exercise let's generate the modulefiles in your ``$HOME/spack-infrastructure/modules`` directory.

.. code-block:: yaml
    :linenos:
    :emphasize-lines: 152-153

    # This is a Spack Environment file.
    #
    # It describes a set of packages to be installed, along with
    # configuration settings.
    spack:
      config:
        view: false
        concretization: separately
        build_stage: $spack/var/spack/stage
        misc_cache: $spack/var/spack/misc_cache
        concretizer: clingo
      compilers:
      - compiler:
          spec: gcc@11.2.0
          paths:
            cc: cc
            cxx: CC
            f77: ftn
            fc: ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-gnu
          - gcc/11.2.0
          - craype-x86-milan
          - libfabric
          extra_rpaths: []
      - compiler:
          spec: cce@13.0.2
          paths:
            cc: /opt/cray/pe/craype/default/bin/cc
            cxx: /opt/cray/pe/craype/default/bin/CC
            f77: /opt/cray/pe/craype/default/bin/ftn
            fc: /opt/cray/pe/craype/default/bin/ftn
          flags: {}
          operating_system: sles15
          target: any
          modules:
          - PrgEnv-cray
          - cce/13.0.2
          - craype-x86-milan
          - libfabric
          environment: {}
          extra_rpaths: []

      # add package specs to the `specs` list
      specs:
      - papi %gcc
      - papi %cce
      - hypre %gcc
      - hypre %cce
      - darshan-runtime %gcc
      - darshan-runtime %cce
      - papi +cuda %gcc
      packages:
        all:
          compiler: [gcc@11.2.0, cce@13.0.2]
          providers:
            blas: [cray-libsci]
            mpi: [cray-mpich]
        bzip2:
          version: [1.0.6]
          externals:
          - spec: bzip2@1.0.6
            prefix: /usr
        cray-libsci:
          buildable: false
          externals:
          - spec: cray-libsci@21.08.1.2
            modules:
            - cray-libsci/21.08.1.2
        cray-mpich:
          buildable: false
          externals:
          - spec: cray-mpich@8.1.15 %gcc@11.2.0
            prefix: /opt/cray/pe/mpich/8.1.15/ofi/gnu/9.1
            modules:
            - cray-mpich/8.1.15
            - cudatoolkit/11.5
          - spec: cray-mpich@8.1.15 %cce@13.0.2
            prefix: /opt/cray/pe/mpich/8.1.15/ofi/cray/10.0/
            modules:
            - cray-mpich/8.1.15
            - cudatoolkit/11.5
        cray-pmi:
          buildable: false
          externals:
          - spec: cray-pmi@6.1.1
            modules:
            - cray-pmi/6.1.1
        cuda:
          buildable: false
          version: [11.5.0]
          externals:
          - spec: cuda@11.5.0
            prefix: /opt/nvidia/hpc_sdk/Linux_x86_64/21.11/cuda/11.5
            modules:
            - cudatoolkit/11.5
        diffutils:
          version: [3.6]
          externals:
          - spec: diffutils@3.6
            prefix: /usr
        findutils:
          version: [4.6.0]
          externals:
          - spec: findutils@4.6.0
            prefix: /usr
        libfabric:
          buildable: false
          variants: fabrics=sockets,tcp,udp,rxm
          externals:
          - spec: libfabric@1.11.0.4.114
            prefix: /opt/cray/libfabric/1.11.0.4.114
            modules:
            - libfabric/1.11.0.4.114
        openssl:
          version: [1.1.0i]
          buildable: false
          externals:
          - spec: openssl@1.1.0i
            prefix: /usr
        openssh:
          version: [7.9p1]
          buildable: false
          externals:
          - spec: openssh@7.9p1
            prefix: /usr
        readline:
          version: [7.0]
          buildable: false
          externals:
          - spec: readline@7.0
            prefix: /usr
        tar:
          version: [1.3]
          buildable: false
          externals:
          - spec: tar@1.30
            prefix: /usr
        unzip:
          version: [6.0]
          buildable: false
          externals:
          - spec: unzip@6.0
            prefix: /usr
      modules:
        default:
          enable:
          - tcl
          roots:
            tcl: /global/homes/s/siddiq90/spack-infrastructure/modules
          tcl:
            blacklist_implicits: true
            hash_length: 0
            naming_scheme: '{name}/{version}-{compiler.name}-{compiler.version}'
            all:
              autoload: direct
              conflict:
              - '{name}'
              environment:
                set:
                  '{name}_ROOT': '{prefix}'
              suffixes:
                ^cuda: cuda

      view: true

Now you will see the modulefiles are written in ``$HOME/spack-infrastructure/modules``.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> spack -d module tcl refresh --delete-tree -y
    ==> [2022-08-04-09:53:00.452047] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/etc/spack/defaults/config.yaml
    ==> [2022-08-04-09:53:00.563502] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/var/spack/environments/data_viz/spack.yaml
    ==> [2022-08-04-09:53:00.617365] Using environment 'data_viz'
    ==> [2022-08-04-09:53:00.625951] Imported module from built-in commands
    ==> [2022-08-04-09:53:00.632039] Imported module from built-in commands
    ==> [2022-08-04-09:53:00.637512] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/etc/spack/defaults/bootstrap.yaml
    ==> [2022-08-04-09:53:00.654001] DATABASE LOCK TIMEOUT: 3s
    ==> [2022-08-04-09:53:00.654065] PACKAGE LOCK TIMEOUT: No timeout
    ==> [2022-08-04-09:53:00.657750] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/etc/spack/defaults/repos.yaml
    ==> [2022-08-04-09:53:00.670487] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/etc/spack/defaults/modules.yaml
    ==> [2022-08-04-09:53:00.687615] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/etc/spack/defaults/cray/modules.yaml
    ==> [2022-08-04-09:53:00.891563] 	BLACKLISTED_AS_IMPLICIT : cray-libsci@21.08.1.2%cce@13.0.2~mpi~openmp+shared arch=cray-sles15-zen3/7uzhxpv
    ==> [2022-08-04-09:53:00.892858] 	BLACKLISTED_AS_IMPLICIT : cray-libsci@21.08.1.2%gcc@11.2.0~mpi~openmp+shared arch=cray-sles15-zen3/jzbnd6y
    ==> [2022-08-04-09:53:00.894129] 	BLACKLISTED_AS_IMPLICIT : cray-mpich@8.1.15%cce@13.0.2+wrappers arch=cray-sles15-zen3/tb5uxwe
    ==> [2022-08-04-09:53:00.895334] 	BLACKLISTED_AS_IMPLICIT : cray-mpich@8.1.15%gcc@11.2.0+wrappers arch=cray-sles15-zen3/3zy6uvs
    ==> [2022-08-04-09:53:00.896502] 	BLACKLISTED_AS_IMPLICIT : cuda@11.5.0%gcc@11.2.0~allow-unsupported-compilers~dev arch=cray-sles15-zen3/puekfe3
    ==> [2022-08-04-09:53:00.904007] 	BLACKLISTED_AS_IMPLICIT : zlib@1.2.12%cce@13.0.2+optimize+pic+shared patches=0d38234 arch=cray-sles15-zen3/e2hl6cx
    ==> [2022-08-04-09:53:00.905394] 	BLACKLISTED_AS_IMPLICIT : zlib@1.2.12%gcc@11.2.0+optimize+pic+shared patches=0d38234 arch=cray-sles15-zen3/ozmcyfj
    ==> [2022-08-04-09:53:03.555915] Regenerating tcl module files
    ==> [2022-08-04-09:53:03.577058] 	WRITE: darshan-runtime@3.3.1%cce@13.0.2~apmpi~apmpi_sync~apxc~hdf5+mpi scheduler=NONE arch=cray-sles15-zen3/uj3wa4a [/global/homes/s/siddiq90/spack-infrastructure/modules/cray-sles15-zen3/darshan-runtime/3.3.1-cce-13.0.2]
    ==> [2022-08-04-09:53:04.003818] Module name: cce/13.0.2
    ==> [2022-08-04-09:53:04.004044] Package directory variable prefix: CCE
    ==> [2022-08-04-09:53:04.248393] Module name: cce/13.0.2
    ==> [2022-08-04-09:53:04.248675] Package directory variable prefix: CCE
    ==> [2022-08-04-09:53:04.484157] Module name: cce/13.0.2
    ==> [2022-08-04-09:53:04.484420] Package directory variable prefix: CCE
    ==> [2022-08-04-09:53:04.766465] Module name: cce/13.0.2
    ==> [2022-08-04-09:53:04.766692] Package directory variable prefix: CCE
    ==> [2022-08-04-09:53:05.024080] Module name: cce/13.0.2
    ==> [2022-08-04-09:53:05.024335] Package directory variable prefix: CCE
    ==> [2022-08-04-09:53:05.043781] 	BLACKLISTED_AS_IMPLICIT : cray-mpich@8.1.15%cce@13.0.2+wrappers arch=cray-sles15-zen3/tb5uxwe
    ==> [2022-08-04-09:53:05.048836] 	BLACKLISTED_AS_IMPLICIT : zlib@1.2.12%cce@13.0.2+optimize+pic+shared patches=0d38234 arch=cray-sles15-zen3/e2hl6cx
    ==> [2022-08-04-09:53:05.055298] Reading config file /global/u1/s/siddiq90/spack-infrastructure/spack/etc/spack/defaults/packages.yaml
    ==> [2022-08-04-09:53:05.111091] 	WRITE: darshan-runtime@3.3.1%gcc@11.2.0~apmpi~apmpi_sync~apxc~hdf5+mpi scheduler=NONE arch=cray-sles15-zen3/hkxzwvt [/global/homes/s/siddiq90/spack-infrastructure/modules/cray-sles15-zen3/darshan-runtime/3.3.1-gcc-11.2.0]
    ==> [2022-08-04-09:53:05.161578] 	BLACKLISTED_AS_IMPLICIT : cray-mpich@8.1.15%gcc@11.2.0+wrappers arch=cray-sles15-zen3/3zy6uvs
    ==> [2022-08-04-09:53:05.164707] 	BLACKLISTED_AS_IMPLICIT : zlib@1.2.12%gcc@11.2.0+optimize+pic+shared patches=0d38234 arch=cray-sles15-zen3/ozmcyfj
    ==> [2022-08-04-09:53:05.171012] 	WRITE: hypre@2.24.0%cce@13.0.2~complex~cuda~debug+fortran~gptune~int64~internal-superlu~mixedint+mpi~openmp~rocm+shared~superlu-dist~unified-memory arch=cray-sles15-zen3/62ofdsf [/global/homes/s/siddiq90/spack-infrastructure/modules/cray-sles15-zen3/hypre/2.24.0-cce-13.0.2]
    ==> [2022-08-04-09:53:05.469562] Module name: cce/13.0.2
    ==> [2022-08-04-09:53:05.469791] Package directory variable prefix: CCE
    ==> [2022-08-04-09:53:05.767046] Module name: cce/13.0.2
    ==> [2022-08-04-09:53:05.767239] Package directory variable prefix: CCE
    ==> [2022-08-04-09:53:06.050449] Module name: cce/13.0.2
    ==> [2022-08-04-09:53:06.050663] Package directory variable prefix: CCE
    ==> [2022-08-04-09:53:06.295722] Module name: cce/13.0.2
    ==> [2022-08-04-09:53:06.295923] Package directory variable prefix: CCE
    ==> [2022-08-04-09:53:06.307895] 	BLACKLISTED_AS_IMPLICIT : cray-libsci@21.08.1.2%cce@13.0.2~mpi~openmp+shared arch=cray-sles15-zen3/7uzhxpv
    ==> [2022-08-04-09:53:06.313024] 	BLACKLISTED_AS_IMPLICIT : cray-mpich@8.1.15%cce@13.0.2+wrappers arch=cray-sles15-zen3/tb5uxwe
    ==> [2022-08-04-09:53:06.321590] 	WRITE: hypre@2.24.0%gcc@11.2.0~complex~cuda~debug+fortran~gptune~int64~internal-superlu~mixedint+mpi~openmp~rocm+shared~superlu-dist~unified-memory arch=cray-sles15-zen3/mbn7bum [/global/homes/s/siddiq90/spack-infrastructure/modules/cray-sles15-zen3/hypre/2.24.0-gcc-11.2.0]
    ==> [2022-08-04-09:53:06.366559] 	BLACKLISTED_AS_IMPLICIT : cray-libsci@21.08.1.2%gcc@11.2.0~mpi~openmp+shared arch=cray-sles15-zen3/jzbnd6y
    ==> [2022-08-04-09:53:06.369882] 	BLACKLISTED_AS_IMPLICIT : cray-mpich@8.1.15%gcc@11.2.0+wrappers arch=cray-sles15-zen3/3zy6uvs
    ==> [2022-08-04-09:53:06.377335] 	WRITE: papi@6.0.0.1%cce@13.0.2~cuda+example~infiniband~lmsensors~nvml~powercap~rapl~rocm~rocm_smi~sde+shared~static_tools patches=b6d6caa arch=cray-sles15-zen3/3aprcx5 [/global/homes/s/siddiq90/spack-infrastructure/modules/cray-sles15-zen3/papi/6.0.0.1-cce-13.0.2]
    ==> [2022-08-04-09:53:06.656390] Module name: cce/13.0.2
    ==> [2022-08-04-09:53:06.656565] Package directory variable prefix: CCE
    ==> [2022-08-04-09:53:06.670466] 	WRITE: papi@6.0.0.1%gcc@11.2.0~cuda+example~infiniband~lmsensors~nvml~powercap~rapl~rocm~rocm_smi~sde+shared~static_tools arch=cray-sles15-zen3/s2y4nrv [/global/homes/s/siddiq90/spack-infrastructure/modules/cray-sles15-zen3/papi/6.0.0.1-gcc-11.2.0]
    ==> [2022-08-04-09:53:06.719655] 	WRITE: papi@6.0.0.1%gcc@11.2.0+cuda+example~infiniband~lmsensors~nvml~powercap~rapl~rocm~rocm_smi~sde+shared~static_tools arch=cray-sles15-zen3/x43djbq [/global/homes/s/siddiq90/spack-infrastructure/modules/cray-sles15-zen3/papi/6.0.0.1-gcc-11.2.0-cuda]
    ==> [2022-08-04-09:53:07.034250] Module name: gcc/11.2.0
    ==> [2022-08-04-09:53:07.034531] Package directory variable prefix: GCC
    ==> [2022-08-04-09:53:07.055549] 	BLACKLISTED_AS_IMPLICIT : cuda@11.5.0%gcc@11.2.0~allow-unsupported-compilers~dev arch=cray-sles15-zen3/puekfe3

We can see that Spack has generated the modulefiles in the format of ``{name}/{version}-{compiler.name}-{compiler.version}``. For example,
the ``-cuda`` suffix was added for the PAPI module that has CUDA-enabled features.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> ls -l $CI_PROJECT_DIR/modules/$(spack arch)/*
    /global/homes/s/siddiq90/spack-infrastructure/modules/cray-sles15-zen3/darshan-runtime:
    total 8
    -rw-r--r-- 1 siddiq90 siddiq90 2245 Aug  4 09:53 3.3.1-cce-13.0.2
    -rw-r--r-- 1 siddiq90 siddiq90 2243 Aug  4 09:53 3.3.1-gcc-11.2.0

    /global/homes/s/siddiq90/spack-infrastructure/modules/cray-sles15-zen3/hypre:
    total 8
    -rw-r--r-- 1 siddiq90 siddiq90 1951 Aug  4 09:53 2.24.0-cce-13.0.2
    -rw-r--r-- 1 siddiq90 siddiq90 1943 Aug  4 09:53 2.24.0-gcc-11.2.0

    /global/homes/s/siddiq90/spack-infrastructure/modules/cray-sles15-zen3/papi:
    total 12
    -rw-r--r-- 1 siddiq90 siddiq90 2441 Aug  4 09:53 6.0.0.1-cce-13.0.2
    -rw-r--r-- 1 siddiq90 siddiq90 2425 Aug  4 09:53 6.0.0.1-gcc-11.2.0
    -rw-r--r-- 1 siddiq90 siddiq90 2503 Aug  4 09:53 6.0.0.1-gcc-11.2.0-cuda

We can add this directory to ``MODULEPATH`` by running the following:

.. code-block:: console

    (spack-pyenv) siddiq90@login34> module use $CI_PROJECT_DIR/modules/$(spack arch)

Next, if we run ``module load av`` we will see the modules generated from Spack that correspond to the installed Spack packages.

.. code-block:: console

    (spack-pyenv) siddiq90@login34> module load av

    ------------------------------------ /global/homes/s/siddiq90/spack-infrastructure/modules/cray-sles15-zen3 -------------------------------------
       darshan-runtime/3.3.1-cce-13.0.2        hypre/2.24.0-cce-13.0.2        papi/6.0.0.1-cce-13.0.2         papi/6.0.0.1-gcc-11.2.0
       darshan-runtime/3.3.1-gcc-11.2.0 (D)    hypre/2.24.0-gcc-11.2.0 (D)    papi/6.0.0.1-gcc-11.2.0-cuda


This concludes the Spack training.
