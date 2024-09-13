# Spack Configuration

This page will show all of our Spack configuration files
([spack.yaml]{.title-ref}) used for our production deployments. The
Spack configuration located in
[spack-configs](https://github.com/NERSC/spack-infrastructure/tree/main/spack-configs)
directory organized by each subdirectory.

At NERSC, we are building the [Extreme-scale Scientific Software Stack
(E4S)](https://e4s.readthedocs.io/en/latest/introduction.html) which is
a collection of open-source products software packages part of Spack
ecosystem for running scientific applications on high-performance
computing (HPC) platforms. We acquire the Spack configuration from
<https://github.com/E4S-Project/e4s> upon release with list of specs and
reference Spack branch in order to build the E4S stack. Please see our
E4S documentation at <https://docs.nersc.gov/applications/e4s/>

## Perlmutter v0.22

This stack is built using
[releases/v0.22](https://github.com/spack/spack/tree/releases/v0.22)
branch

::::: dropdown
Production Spack Configuration

GCC spack environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-v0.22/prod/gcc/spack.yaml
:::

CUDA spack environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-v0.22/prod/cuda/spack.yaml
:::
:::::

Shown below is the definitions.yaml that is appended to each spack
configuration prior to deployment

:::: dropdown
Definition File

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-v0.22/definitions.yaml
:::
::::

## Perlmutter E4S 23.08

This stack is built with spack branch
[e4s-23.08](https://github.com/spack/spack/tree/e4s-23.08)

::::::: dropdown
Production Spack Configuration

GCC spack environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-23.08/prod/gcc/spack.yaml
:::

CUDA spack environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-23.08/prod/cuda/spack.yaml
:::

NVHPC spack environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-23.08/prod/nvhpc/spack.yaml
:::

CCE spack environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-23.08/prod/cce/spack.yaml
:::
:::::::

Shown below is the definitions file used for this spack environment

:::: dropdown
Definition File

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-23.08/definitions.yaml
:::
::::

## Perlmutter E4S 23.05

:::::::::: dropdown
Production Spack Configuration

GCC spack environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-23.05/prod/gcc/spack.yaml
:::

CCE Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-23.05/prod/cce/spack.yaml
:::

NVHPC Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-23.05/prod/nvhpc/spack.yaml
:::

CUDA Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-23.05/prod/cuda/spack.yaml
:::

DATA Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-23.05/prod/data/spack.yaml
:::

MATH-LIBS Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-23.05/prod/math-libs/spack.yaml
:::

TOOLS Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-23.05/prod/tools/spack.yaml
:::
::::::::::

Shown below is the list of definitions that is used for all of our spack
environments.

:::: dropdown
Definitions for Spack Environments

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-23.05/definitions.yaml
:::
::::

## Perlmutter E4S 22.11

::::::: dropdown
Production Spack Configuration

GCC spack environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-22.11/prod/gcc/spack.yaml
:::

CCE Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-22.11/prod/cce/spack.yaml
:::

NVHPC Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-22.11/prod/nvhpc/spack.yaml
:::

CUDA Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-22.11/prod/cuda/spack.yaml
:::
:::::::

Shown below is the list of definitions that is used for all of our spack
environments.

:::: dropdown
Definitions for Spack Environments

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-22.11/definitions.yaml
:::
::::

## Perlmutter E4S 22.05

Shown below is the production Spack configuration for Perlmutter E4S
22.05. You can access this stack via `module load e4s/22.05` on
Perlmutter. Please see our user documentation for this stack at
<https://docs.nersc.gov/applications/e4s/perlmutter/22.05/>.

::::::: dropdown
Production Spack Configuration

GCC spack environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-22.05/prod/gcc/spack.yaml
:::

CCE Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-22.05/prod/cce/spack.yaml
:::

NVHPC Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-22.05/prod/nvhpc/spack.yaml
:::

CUDA Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-22.05/prod/cuda/spack.yaml
:::
:::::::

Shown below is the list of definitions that is used for all of our spack
environments.

:::: dropdown
Definitions for Spack Environments

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-22.05/definitions.yaml
:::
::::

## Perlmutter E4S 21.11

Shown below is the production Spack configuration for Perlmutter E4S
21.11. You can access this stack via `module load e4s/21.11` or
`module load e4s/21.11` on Perlmutter. Please see our user documentation
for this stack at
<https://docs.nersc.gov/applications/e4s/perlmutter/21.11/>.

::::: dropdown
Production Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-21.11/prod/spack.yaml
:::

::: {.literalinclude language="yaml"}
../spack-configs/perlmutter-e4s-21.11/definitions.yaml
:::
:::::

## Cori E4S 22.02

:::: dropdown
Production Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/cori-e4s-22.02/spack.yaml
:::
::::

## Cori E4S 21.05

:::: dropdown
Production Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/cori-e4s-21.05/spack.yaml
:::
::::

## Cori E4S 21.02

:::: dropdown
Production Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/cori-e4s-21.02/prod/spack.yaml
:::
::::

## Cori E4S 20.10

:::: dropdown
Production Spack Environment

::: {.literalinclude language="yaml"}
../spack-configs/cori-e4s-20.10/prod/spack.yaml
:::
::::
