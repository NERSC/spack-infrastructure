# Spack Infrastructure

The spack infrastructure repository contains spack configuration in the form of `spack.yaml` required to build spack stacks on Cori and Perlmutter system. We leverage gitlab to automate software stack deployment which is configured using the [.gitlab-ci.yml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/.gitlab-ci.yml) file. The documentation is available at https://nersc-spack-infrastructure.rtfd.io/

## Spack Configuration

The spack configuration can be found in [spack-configs](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs) directory with subdirectory for each deployment.
Each pipeline can be run if one sets the variable `PIPELINE_NAME` to a unique value in order to run a pipeline. You can check the [.gitlab-ci.yml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/.gitlab-ci.yml) for the gitlab configuration. The pipeline can be run via [web interface](https://software.nersc.gov/NERSC/spack-infrastructure/-/pipelines/new), if you chose this route, you must set `PIPELINE_NAME` to the appropriate value.

If you want to trigger pipeline via [web-interface](https://software.nersc.gov/NERSC/spack-infrastructure/-/pipelines/new) you will need to define PIPELINE_NAME variable to trigger the appropriate pipeline.


## Running CI Pipelines

This project is configured with several [scheduled pipelines](https://software.nersc.gov/NERSC/spack-infrastructure/-/pipeline_schedules) that will run at different times.

Currently, we have a shell runner installed on Perlmutter using `e4s` account which is configured with following settings. You can find list of runners and their runner status under [Settings > CI/CD > Runners](https://software.nersc.gov/NERSC/spack-infrastructure/-/settings/ci_cd). Please make sure you login to the appropriate hostname when starting the gitlab runner.

| System | Runner Name | Hostname |
| --------- | ---------- | -------- |
| perlmutter | `perlmutter-e4s` | `login27` |
| cori | `cori-e4s` | `cori02` |
| muller | `muller-e4s` | `login02` |
| gerty | `gerty-e4s` | `gert01` |

The runner configuration files are located in `~/.gitlab-runner` for user **e4s**.

The production pipelines are triggered via web-interface which requires approval from a project maintainer. Production pipelines should be run when we need to do full redeployment of stack.

## Current Challenges

There are several challenges with building spack stack at NERSC which can be summarized as follows

- **System OS + Cray Programming Environment (CPE) changes**: A system upgrade such as change to `glibc` or upgrades in CPE can lead to full software stack rebuild, especially if you have external packages set for packages like `cray-mpich`, `cray-libsci` which generally change between versions
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

There is a document [Spack E4S Issues on Permlutter](https://docs.google.com/document/d/1jWrCcK8LgpNDMytXhLdBYpIusidkoowrZAH1zos7zIw/edit?usp=sharing) outlining current issues with spack. If you need access to document please contact **Shahzeb Siddiqui**.

## Contact

If you need elevated privledge or assistance with this project please contact one of the maintainers:

- **Shahzeb Siddiqui (shahzebsiddiqui@lbl.gov)**
- **Erik Palmer (epalmer@lbl.gov)**
- **Justin Cook (JSCook@lbl.gov)**
- E4S Team: **Sameer Shende (sameer@cs.uoregon.edu)**, **Christopher Peyralans (lpeyrala@uoregon.edu)**, **Wyatt Spear (wspear@cs.uoregon.edu)**, **Nicholas Chaimov (nchaimov@paratools.com)**


