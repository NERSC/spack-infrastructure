# Spack Infrastructure

The spack infrastructure repository contains spack configuration in the form of `spack.yaml` required to build spack stacks on Cori and Perlmutter system. The use-cases will vary which we will cover in detail. 

There are several challenges with building spack stack at NERSC which can be summarized as follows

- **System OS + Cray PE changes**: A system upgrade such as change to `glibc` or upgrades in Cray Programming Environment can lead to full software stack rebuild, especially if you have externals set to packages like `cray-mpich`, `cray-libsci` which generally change between versions
- **Incompatibile compilers**: Some packages can't be built with certain compilers (`nvhpc`, `aocc`) which could be due to several factors. 
  - An application doesn't have support though it was be added in newer version but you don't have it in your spack release used for deployment
  - Lack of support in spack package recipe or spack-core base including spack-cray detection. This may require getting fix and cherry-pick commit or waiting for new version
  - Spack Cray detection is an important part in build errors including how one specifies externals via `modules` vs `prefix` both could be provided and it requires experimentation. An example of this is trying to get `cray-mpich` external one could set something like this with modules or prefix

  ```yaml
    cray-mpich:
      buildable: false
      externals:
      - spec: cray-mpich@8.1.11 %gcc@9.3.0
        prefix: /opt/cray/pe/mpich/8.1.11/ofi/gnu/9.1
        modules:
        - cray-mpich/8.1.11
        - cudatoolkit/21.9_11.4
  ```
  - **Spack concretizer** prevent one from chosing a build configration for a spec. This requires a few troubleshooting step but usually boils down to:
    - Read the spack package file `spack edit <package>`
    - Try different version, different compiler, different dependency. Some packages have conflicting variant for instance one can't enable `+openmp` and `+pthread` it is mutually exclusive


## Spack Configuration

The spack configuration can be found in [spack-configs](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs) directory with subdirectory for each deployment. 

- [spack-configs/cori-e4s-20.10](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs/cori-e4s-20.10) - E4S/20.10 deployment on Cori. This project lives in https://software.nersc.gov/NERSC/e4s-2010 and configuration was copied over here. This stack is complete and requires no further changes

- [spack-configs/cori-e4s-21.02](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs/cori-e4s-21.02) - E4S/21.02 deployment on Cori. This project lives in https://software.nersc.gov/NERSC/e4s-2102 and configuration was copied over here. This stack is complete and requires no further changes

- [spack-configs/perlmutter-e4s-21.11](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs/perlmutter-e4s-21.11) - This directory contains E4S/21.11 configuration for Perlmutter. The configuration file [spack-configs/perlmutter-e4s-21.11/spack.yaml](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs/perlmutter-e4s-21.11) is the production deployment for E4S/21.11 which should only be changed if deployment needs to be fixed. The deployment changes should be staged in [spack-configs/perlmutter-e4s-21.11/ci/spack.yaml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/perlmutter-e4s-21.11/ci/spack.yaml) which does a full rebuild of E4S 21.11 from source to stack can be built. 

- [spack-configs/perlmutter-spack-develop](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs/perlmutter-spack-develop) - This directory contains a spack.yaml used with `spack@develop` branch to see what packages can be built. We expect this pipeline will fail and we are not expected to fix build failure. The main purpose of this project is to build as many packages across all the compilers, mpi, blas providers of interest and see what works. Since we don't know which package works during deployment, we will leverage data from this pipeline to make informed decision what packages should be picked with given compilers. This pipeline is our development and we should use this to experiment new compilers. Note that we won't hardcode versions for packages since we want to build with latest release. However we will hardcode externals depending on how system is configured.

- [spack-configs/perlmutter-systemlayer](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs/perlmutter-systemlayer) - This directory contains a spack configuration used for building out the system layer which includes compilers, mpi, blas providers, nvhpc and several other important tools. The [spack-configs/perlmutter-systemlayer/spack.yaml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/perlmutter-systemlayer/spack.yaml) is the production deployment whereas [spack-configs/perlmutter-systemlayer/ci/spack.yaml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/perlmutter-systemlayer/ci/spack.yaml) is spack configuration used for full rebuilds that will run on scheduled pipeline.


## Scheduled Pipelines

This project is configured with several [scheduled pipelines](https://software.nersc.gov/NERSC/spack-infrastructure/-/pipeline_schedules) that will run at different times.

Currently, we have a shell runner installed on Perlmutter using `e4s` account which is configured with following settings. You can find list of runners and their runner status under [Settings > CI/CD > Runners](https://software.nersc.gov/NERSC/spack-infrastructure/-/settings/ci_cd).

| Hostname | Runner Name | Runner Configuration |
| --------- | ---------- | --------------------- |
| login21 | `perlmutter-login21` | ` ~/.gitlab-runner/perlmutter-login21.config.toml` |


Each pipeline sets the variable `PIPELINE_NAME` to a unique value in order to run a pipeline. You can check the [.gitlab-ci.yml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/.gitlab-ci.yml) for the gitlab configuration. The pipeline can be run via [web interface](https://software.nersc.gov/NERSC/spack-infrastructure/-/pipelines/new), if you chose this route, you must set `PIPELINE_NAME` to the appropriate value.

## Contact

If you need with project setting please contact **Shahzeb Siddiqui (shahzebsiddiqui@lbl.gov)**

