Spack Configuration
===================

This page will show all of our Spack configuration files (`spack.yaml`) used for our production deployments. The
Spack configuration located in `spack-configs <https://github.com/NERSC/spack-infrastructure/tree/main/spack-configs>`_ directory
organized by each subdirectory.

At NERSC, we are building the `Extreme-scale Scientific Software Stack (E4S) <https://e4s.readthedocs.io/en/latest/introduction.html>`_ which
is a collection of open-source products software packages part of Spack ecosystem for running scientific applications on high-performance
computing (HPC) platforms. We acquire the Spack configuration from https://github.com/E4S-Project/e4s upon release with list of specs and reference
Spack branch in order to build the E4S stack. Please see our E4S documentation at https://docs.nersc.gov/applications/e4s/


Perlmutter v0.22
-----------------

This stack is built using `releases/v0.22 <https://github.com/spack/spack/tree/releases/v0.22>`_ branch 

.. dropdown:: Production Spack Configuration

    GCC spack environment

    .. literalinclude:: ../spack-configs/perlmutter-v0.22/prod/gcc/spack.yaml
        :language: yaml

    CUDA spack environment

    .. literalinclude:: ../spack-configs/perlmutter-v0.22/prod/cuda/spack.yaml
        :language: yaml

Shown below is the definitions.yaml that is appended to each spack configuration prior to deployment

.. literalinclude:: ../spack-configs/perlmutter-v0.22/definitions.yaml
    :language: yaml

Perlmutter E4S 23.08
---------------------

This stack is built with spack branch `e4s-23.08 <https://github.com/spack/spack/tree/e4s-23.08>`_

.. dropdown:: Production Spack Configuration

    GCC spack environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-23.08/prod/gcc/spack.yaml
        :language: yaml

    CUDA spack environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-23.08/prod/cuda/spack.yaml
        :language: yaml


    NVHPC spack environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-23.08/prod/nvhpc/spack.yaml
        :language: yaml


    CCE spack environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-23.08/prod/cce/spack.yaml
        :language: yaml
    

Shown below is the definitions file used for this spack environment

.. literalinclude:: ../spack-configs/perlmutter-e4s-23.08/definitions.yaml
    :language: yaml

Perlmutter E4S 23.05
----------------------

.. dropdown:: Production Spack Configuration

        GCC spack environment

        .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/prod/gcc/spack.yaml
            :language: yaml

        CCE Spack Environment

        .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/prod/cce/spack.yaml
            :language: yaml

        NVHPC Spack Environment

        .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/prod/nvhpc/spack.yaml
            :language: yaml

        CUDA Spack Environment

        .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/prod/cuda/spack.yaml
            :language: yaml

        DATA Spack Environment

        .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/prod/data/spack.yaml
            :language: yaml

        MATH-LIBS Spack Environment

        .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/prod/math-libs/spack.yaml
            :language: yaml

        TOOLS Spack Environment

        .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/prod/tools/spack.yaml
            :language: yaml

Shown below is the list of definitions that is used for all of our spack environments.

.. dropdown:: Definitions for Spack Environments

    .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/definitions.yaml
        :language: yaml

Each spack environment is built in a separate directory using **spack ci** in-order to push specs to buildcache.
We have the following spack configuration for each spack environment.

.. dropdown:: Spack Environments for Spack CI

    GCC Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/gcc/spack.yaml
        :language: yaml

    CCE Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/cce/spack.yaml
        :language: yaml

    NVHPC Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/nvhpc/spack.yaml
        :language: yaml

    CUDA Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/cuda/spack.yaml
        :language: yaml

    DATA Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/data/spack.yaml
        :language: yaml

    MATH-LIBS Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/math-libs/spack.yaml
        :language: yaml

    TOOLS Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-23.05/tools/spack.yaml
        :language: yaml
        
Perlmutter E4S 22.11
----------------------

.. dropdown:: Production Spack Configuration

        GCC spack environment

        .. literalinclude:: ../spack-configs/perlmutter-e4s-22.11/prod/gcc/spack.yaml
            :language: yaml

        CCE Spack Environment

        .. literalinclude:: ../spack-configs/perlmutter-e4s-22.11/prod/cce/spack.yaml
            :language: yaml

        NVHPC Spack Environment

        .. literalinclude:: ../spack-configs/perlmutter-e4s-22.11/prod/nvhpc/spack.yaml
            :language: yaml

        CUDA Spack Environment

        .. literalinclude:: ../spack-configs/perlmutter-e4s-22.11/prod/cuda/spack.yaml
            :language: yaml

Shown below is the list of definitions that is used for all of our spack environments.

.. dropdown:: Definitions for Spack Environments

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.11/definitions.yaml
        :language: yaml

Each spack environment is built in a separate directory using **spack ci** in-order to push specs to buildcache.
We have the following spack configuration for each spack environment.

.. dropdown:: Spack Environments for Spack CI

    GCC Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.11/gcc/spack.yaml
        :language: yaml

    CCE Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.11/cce/spack.yaml
        :language: yaml

    NVHPC Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.11/nvhpc/spack.yaml
        :language: yaml

    CUDA Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.11/cuda/spack.yaml
        :language: yaml

Perlmutter E4S 22.05
----------------------

Shown below is the production Spack configuration for Perlmutter E4S 22.05. You can access this stack
via ``module load e4s/22.05``  on Perlmutter. Please see
our user documentation for this stack at https://docs.nersc.gov/applications/e4s/perlmutter/22.05/.

.. dropdown:: Production Spack Configuration

    GCC spack environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.05/prod/gcc/spack.yaml
        :language: yaml

    CCE Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.05/prod/cce/spack.yaml
        :language: yaml

    NVHPC Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.05/prod/nvhpc/spack.yaml
        :language: yaml

    CUDA Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.05/prod/cuda/spack.yaml
        :language: yaml

Shown below is the list of definitions that is used for all of our spack environments.

.. dropdown:: Definitions for Spack Environments

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.05/definitions.yaml
        :language: yaml

Shown below is the list of spack environments that is used for building the stack into buildcache using **spack ci**.

.. dropdown:: Spack Environments for Spack CI

    GCC Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.05/gcc/spack.yaml
        :language: yaml

    CCE Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.05/cce/spack.yaml
        :language: yaml

    NVHPC Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.05/nvhpc/spack.yaml
        :language: yaml

    CUDA Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-22.05/cuda/spack.yaml
        :language: yaml

Perlmutter E4S 21.11
----------------------

Shown below is the production Spack configuration for Perlmutter E4S 21.11. You can access this stack
via ``module load e4s/21.11`` or ``module load e4s/21.11`` on Perlmutter. Please see
our user documentation for this stack at https://docs.nersc.gov/applications/e4s/perlmutter/21.11/.

.. dropdown:: Production Spack Environment

    .. literalinclude:: ../spack-configs/perlmutter-e4s-21.11/prod/spack.yaml
        :language: yaml

    .. literalinclude:: ../spack-configs/perlmutter-e4s-21.11/definitions.yaml
        :language: yaml

Cori E4S 22.02
----------------

.. dropdown:: Production Spack Environment

    .. literalinclude:: ../spack-configs/cori-e4s-22.02/spack.yaml
        :language: yaml


Cori E4S 21.05
---------------

.. dropdown:: Production Spack Environment

    .. literalinclude:: ../spack-configs/cori-e4s-21.05/spack.yaml
        :language: yaml


Cori E4S 21.02
---------------

.. dropdown:: Production Spack Environment

    .. literalinclude:: ../spack-configs/cori-e4s-21.02/prod/spack.yaml
        :language: yaml

Cori E4S 20.10
---------------

.. dropdown:: Production Spack Environment

    .. literalinclude:: ../spack-configs/cori-e4s-20.10/prod/spack.yaml
        :language: yaml
