Spack Configuration
===================

This page will show all of our Spack configuration files (`spack.yaml`) used for our production deployments. The
Spack configuration located in `spack-configs <https://github.com/NERSC/spack-infrastructure/tree/main/spack-configs>`_ directory
organized by each subdirectory.

At NERSC, we are building the `Extreme-scale Scientific Software Stack (E4S) <https://e4s.readthedocs.io/en/latest/introduction.html>`_ which
is a collection of open-source products software packages part of Spack ecosystem for running scientific applications on high-performance
computing (HPC) platforms. We acquire the Spack configuration from https://github.com/E4S-Project/e4s upon release with list of specs and reference
Spack branch in order to build the E4S stack. Please see our E4S documentation at https://docs.nersc.gov/applications/e4s/


Perlmutter Spack Develop
-------------------------

This Spack configuration will build all packages using Spack `develop` branch on weekly basis. All specs are specified
without any version in order to let Spack build the latest package which will evolve over time. This stack can be accessible via
``module load e4s/spack-develop``. For more information see https://docs.nersc.gov/applications/e4s/e4s-develop/

.. literalinclude:: ../spack-configs/perlmutter-spack-develop/spack.yaml
   :language: yaml

Perlmutter E4S 22.05
----------------------

Shown below is the production Spack configuration for Perlmutter E4S 21.11. You can access this stack
via ``module load e4s/22.05``  on Perlmutter. Please see
our user documentation for this stack at https://docs.nersc.gov/applications/e4s/perlmutter/22.05/.

.. literalinclude:: ../spack-configs/perlmutter-e4s-22.05/spack.yaml
    :language: yaml

Perlmutter E4S 21.11
----------------------

Shown below is the production Spack configuration for Perlmutter E4S 21.11. You can access this stack
via ``module load e4s/21.11-tcl`` or ``module load e4s/21.11-lmod`` on Perlmutter. Please see
our user documentation for this stack at https://docs.nersc.gov/applications/e4s/perlmutter/21.11/.

.. literalinclude:: ../spack-configs/perlmutter-e4s-21.11/spack.yaml
    :language: yaml

Cori Spack Develop
--------------------

This is the Spack configuration for Spack ``develop`` branch for Cori. Similar to Perlmutter, this stack will build all specs unconstrained
with version.

.. literalinclude:: ../spack-configs/cori-spack-develop/spack.yaml
    :language: yaml

Cori E4S 22.02
----------------

.. literalinclude:: ../spack-configs/cori-e4s-22.02/spack.yaml
    :language: yaml



Cori E4S 21.05
---------------

.. literalinclude:: ../spack-configs/cori-e4s-21.05/spack.yaml
    :language: yaml


Cori E4S 21.02
---------------

.. literalinclude:: ../spack-configs/cori-e4s-21.02/prod/spack.yaml
    :language: yaml

Cori E4S 20.10
---------------

.. literalinclude:: ../spack-configs/cori-e4s-20.10/prod/spack.yaml
    :language: yaml
