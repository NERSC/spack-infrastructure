# Spack Infrastructure

The spack infrastructure repository contains spack configuration in the form of `spack.yaml` required to build spack stacks on Cori and Perlmutter system. The use-cases will vary which we will cover in detail. 

There are several challenges with building spack stack at NERSC which can be summarized as follows

- **System OS + Cray Programming Environment (CPE) changes**: A system upgrade such as change to `glibc` or upgrades in CPE can lead to full software stack rebuild, especially if you have externals set to packages like `cray-mpich`, `cray-libsci` which generally change between versions
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
    - Read the spack package file `spack edit <package>` for conflicts and try `spack spec` to see concretized spec.
    - Try different version, different compiler, different dependency. Some packages have conflicting variant for instance one can't enable `+openmp` and `+pthread` it is mutually exclusive.


## Spack Configuration

The spack configuration can be found in [spack-configs](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs) directory with subdirectory for each deployment. 

| spack.yaml | system | status | description | 
| ---------- | ------- | ----------- | --------- |
| [spack-configs/perlmutter-spack-develop/spack.yaml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/perlmutter-spack-develop/spack.yaml) | Perlmutter | IN-PROGRESS | This spack configuration is based on `spack@develop` branch to see what packages can be built. We expect this pipeline will fail and we are not expected to fix build failure. The main purpose of this project is to build as many packages across all the compilers, mpi, blas providers of interest and see what works. Since we don't know which package works during deployment, we will leverage data from this pipeline to make informed decision what packages should be picked with given compilers. This pipeline is our development and we should use this to experiment new compilers. Note that we won't hardcode versions for packages since we want to build with latest release. However we will hardcode externals depending on how system is configured. |
| [spack-configs/perlmutter-systemlayer/spack.yaml](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs/perlmutter-systemlayer/spack.yaml) | Perlmutter | IN-PROGRESS | This contains a spack configuration used for building the system layer for Perlmutter which will be used for providing a consistent set of compilers that won't change due to Cray Programming Environment (CPE) upgrade. This is meant to be with E4S deployment and **spack@develop** pipeline. The system layer includes compilers, mpi, blas/fftw/lapack/scalapack, nvhpc and other important tools. This configuration is used for deployment purposes and is accessible via `module load systemlayer` |
| [spack-configs/perlmutter-e4s-21.11/spack.yaml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/perlmutter-e4s-21.11/spack.yaml) | Perlmutter | IN-PROGRESS | This spack configuration is deployment configuration for E4S/21.11. | 
| [spack-configs/perlmutter-e4s-21.11/ci/spack.yaml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/perlmutter-e4s-21.11/ci/spack.yaml) | Perlmutter | IN-PROGRESS | This spack configuration is used for development for building E4S/21.11 using scheduled pipeline. | 
| [spack-configs/perlmutter-systemlayer/ci/spack.yaml](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs/perlmutter-systemlayer/ci/spack.yaml) | Perlmutter | IN-PROGRESS | This spack configuration used for building the system layer used with scheduled pipeline in order to do full rebuild of system layer when needed. Once full rebuild is complete, the deployment configuration can be used to redeploy system layer. All changes for systemlayer should happen in this spack configuration |
| [spack-configs/cori-e4s-21.02/prod/spack.yaml](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs/cori-e4s-21.02/prod/spack.yaml) | Cori | COMPLETE | E4S/21.02 spack configuration used for deployment purposes, this can be accessed via `module load e4s/21.02` on Cori. For more details see https://docs.nersc.gov/applications/e4s/cori/21.02/ | 
| [spack-configs/cori-e4s-21.02/spack.yaml](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs/cori-e4s-21.02/spack.yaml) | Cori | COMPLETE | E4S/21.02 spack configuration that push to buildcache. | 
| [spack-configs/cori-e4s-20.10/spack.yaml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/cori-e4s-20.10/spack.yaml) | Cori | COMPLETE |  E4S/20.10 spack configuration that push to build cache using `spack ci`.  This project lives in https://software.nersc.gov/NERSC/e4s-2010 and configuration was copied over here. | 
| [spack-configs/cori-e4s-20.10/prod/spack.yaml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/cori-e4s-20.10/prod/spack.yaml) | Cori | COMPLETE |  E4S/20.10 spack configuration for Cori used for deployment purpose. This stack can be accessed via `module load e4s/20.10`. This is documented at https://docs.nersc.gov/applications/e4s/cori/20.10/ | 

## Scheduled Pipelines

This project is configured with several [scheduled pipelines](https://software.nersc.gov/NERSC/spack-infrastructure/-/pipeline_schedules) that will run at different times.

Currently, we have a shell runner installed on Perlmutter using `e4s` account which is configured with following settings. You can find list of runners and their runner status under [Settings > CI/CD > Runners](https://software.nersc.gov/NERSC/spack-infrastructure/-/settings/ci_cd).

| Hostname | Runner Name | Runner Configuration |
| --------- | ---------- | --------------------- |
| login21 | `perlmutter-login21` | ` ~/.gitlab-runner/perlmutter-login21.config.toml` |


Each pipeline sets the variable `PIPELINE_NAME` to a unique value in order to run a pipeline. You can check the [.gitlab-ci.yml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/.gitlab-ci.yml) for the gitlab configuration. The pipeline can be run via [web interface](https://software.nersc.gov/NERSC/spack-infrastructure/-/pipelines/new), if you chose this route, you must set `PIPELINE_NAME` to the appropriate value.

## Contact

If you need elevated privledge or assistance with this project please contact one of the maintainers:

- **Shahzeb Siddiqui (shahzebsiddiqui@lbl.gov)**
- E4S Team: **Sameer Shende (sameer@cs.uoregon.edu)**, **Christopher Peyralans (lpeyrala@uoregon.edu)**, **Wyatt Spear (wspear@cs.uoregon.edu)**, **Nicholas Chaimov (nchaimov@paratools.com)**

