# Spack Infrastructure

The spack infrastructure repository contains spack configuration in the form of `spack.yaml` required to build spack stacks on Cori and Perlmutter system. We leverage gitlab to automate software stack deployment which is configured using the [.gitlab-ci.yml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/.gitlab-ci.yml) file. The documentation is available at https://nersc-spack-infrastructure.rtfd.io/

## Spack Configuration

The spack configuration can be found in [spack-configs](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs) directory with subdirectory for each deployment.
Each pipeline can be run if one sets the variable `PIPELINE_NAME` to a unique value in order to run a pipeline. You can check the [.gitlab-ci.yml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/.gitlab-ci.yml) for the gitlab configuration. The pipeline can be run via [web interface](https://software.nersc.gov/NERSC/spack-infrastructure/-/pipelines/new), if you chose this route, you must set `PIPELINE_NAME` to the appropriate value.

If you want to trigger pipeline via [web-interface](https://software.nersc.gov/NERSC/spack-infrastructure/-/pipelines/new) you will need to define PIPELINE_NAME variable to trigger the appropriate pipeline.


| system | status | PIPELINE_NAME |  description | spack.yaml |
| ---------- | ------- | ----------- | -------- | ------------ |
| Perlmutter | **IN-PROGRESS** | `PERLMUTTER_SPACK_DEVELOP` | This spack configuration is based on `spack@develop` branch to see what packages can be built. We expect this pipeline will fail and we are not expected to fix build failures. The main purpose of this project is to build as many packages across all the compilers, mpi, and blas providers of interest to see what works. Since we don't know which package works during deployment, we will leverage data from this pipeline to make informed decision what packages should be picked with given compilers. This pipeline is our development and we should use this to experiment new compilers. Note that we won't hardcode versions for packages since we want to build with latest release. However we will hardcode external packages depending on how the system is configured. | https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/perlmutter-spack-develop/spack.yaml |
| Cori | **IN-PROGRESS** | `CORI_SPACK_DEVELOP` | This spack configuration will build E4S stack using spack `develop` branch on Cori. | https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/cori-spack-develop/spack.yaml |
| Perlmutter | **IN-PROGRESS** |  `PERLMUTTER_E4S_22.05` | This spack configuration will build E4S 22.05 on Perlmutter on scheduled pipeline | https://software.nersc.gov/-/ide/project/NERSC/spack-infrastructure/tree/main/-/spack-configs/perlmutter-e4s-22.05/ci/spack.yaml/ |
| Muller | **IN-PROGRESS** |  `MULLER_E4S_22.05` | This spack configuration will build E4S 22.05 on Muller on scheduled pipeline | https://software.nersc.gov/-/ide/project/NERSC/spack-infrastructure/tree/main/-/spack-configs/perlmutter-e4s-22.05/ci/spack.yaml/ |
| Cori | **COMPLETE** | `CORI_E4S_22.02` | This spack configuration will build E4S/22.02 on Cori using a scheduled pipeline. | https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/cori-e4s-22.02/ci/spack.yaml |
| Gerty | **COMPLETE** | `GERTY_E4S_22.02` | This spack configuration will build E4S/22.02 on gerty using a scheduled pipeline. | https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/cori-e4s-22.02/ci/gerty/spack.yaml |
| Perlmutter | **COMPLETE** | `PERLMUTTER_E4S_21.11_DEPLOY` | This spack configuration is deployment configuration for E4S/21.11. For more details on this stack see  https://docs.nersc.gov/applications/e4s/perlmutter/21.11/ | https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/perlmutter-e4s-21.11/spack.yaml |
Perlmutter | **COMPLETE** | `PERLMUTTER_E4S_21.11` | This spack configuration is used for development for building E4S/21.11 using scheduled pipeline. | https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/perlmutter-e4s-21.11/ci/spack.yaml |
| Muller | **COMPLETE** | `MULLER_E4S_21.11` | This spack configuration was used to build E4S/21.11 on Muller using scheduled pipeline. Once e4s/21.11 was built on Muller we followed up with building the same spack configuration on Perlmutter. | https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/perlmutter-e4s-21.11/ci/muller/spack.yaml |
| Cori | **COMPLETE** | | E4S/21.05 spack stack based on [e4s-21.05](https://github.com/spack/spack/tree/e4s-21.05) branch of spack. This stack can be accessed via `module load e4s/21.05`. | https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/cori-e4s-21.05/spack.yaml |
| Cori | **COMPLETE** | | E4S/21.02 spack configuration used for deployment purposes, this can be accessed via `module load e4s/21.02` on Cori. For more details see https://docs.nersc.gov/applications/e4s/cori/21.02/ | https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main/spack-configs/cori-e4s-21.02/prod/spack.yaml |
| Cori | **COMPLETE** | | E4S/21.02 spack configuration that push to buildcache. | https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/cori-e4s-21.02/spack.yaml |
| Cori | **COMPLETE** |  | E4S/20.10 spack configuration that push to build cache using `spack ci`.  This project lives in https://software.nersc.gov/NERSC/e4s-2010 and configuration was copied over here. | https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/cori-e4s-20.10/spack.yaml |
| Cori | **COMPLETE** |  | E4S/20.10 spack configuration for Cori used for deployment purpose. This stack can be accessed via `module load e4s/20.10`. This is documented at https://docs.nersc.gov/applications/e4s/cori/20.10/ | https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/spack-configs/cori-e4s-20.10/prod/spack.yaml |

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

## Troubleshooting gitlab runner

You will need to login as `e4s` user via `collabsu` or `usgrsu` command. This will prompt you for a password which is your **NERSC password** for your username not **e4s** user. Note that `collabsu` is not present on Perlmutter so you must use `usgrsu` to switch user accounts.

```
collabsu e4s
```

Once you are logged in, you can login to the desired system to restart the runner. You can check the runner status by navigating to [Settings > CI/CD > Runners](https://software.nersc.gov/NERSC/spack-infrastructure/-/settings/ci_cd). If the gitlab runner is down you will need to restart the runner which is located in `$HOME/cron` directory for the e4s user.


The `gitlab-runner` command should be accessible via the e4s user. To register a runner you can run `gitlab-runner register` and follow the prompt. The runner configuration will be written to `~/.gitlab-runner/config.toml`. However we recommend you create a separate `config.toml` or copy the file to separate location. For instance if you want to register a runner for muller you can set `gitlab-runner register -c ~/.gitlab-runner/muller.config.toml` when registering the runner and it will write the runner configuration to `~/.gitlab-runner/muller.config.toml`. For more details regarding runner registration please see https://docs.gitlab.com/runner/register/.

To restart a runner you can run the [restart-gitlab.sh](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/restart-gitlab.sh) script which should be present in **$HOME/cron**.

```
bash $HOME/cron/restart-gitlab.sh
```

You can check if the gitlab process is running via `pgrep` assuming you are on the right node. Shown below is an example output, you should only see one gitlab runner process running on a node.

```
e4s:login27> pgrep -a -u e4s gitlab-runner
52769 gitlab-runner run -c /global/homes/e/e4s/.gitlab-runner/perlmutter.config.toml
```

Sometimes you may see unexpected results during CI jobs if you made changes to the gitlab configuration and you have multiple gitlab-runner processes running on different nodes. Therefore, we recommend you use `pdsh` to search for all process across all nodes to find the process and then terminate it. For instance you can run **pgrep** across all Cori login nodes (**cori01-12**) to find any gitlab process, if you see multiple process then you can login to that particular node and terminate the process.

```
pdsh -w cori[01-12] pgrep -a -u e4s gitlab-runner
```

## Jacamar

The gitlab runnners are using [Jacamar CI](https://gitlab.com/ecp-ci/jacamar-ci), there should be a `jacamar.toml` file in the following location:

```
e4s:login27> ls -l ~/.gitlab-runner/jacamar.toml
-rw-rw-r-- 1 e4s e4s 758 Aug 11 08:57 /global/homes/e/e4s/.gitlab-runner/jacamar.toml
```

Any updates to the jacamar configuration are applied to runner and there is no need to restart gitlab runner.


The binaries `jacamar` and `jacamar-auth` are located in the following location, if we need to upgrade jacamar we should place them in this location,

```
e4s:login27> ls -l ~/jacamar/binaries/
total 15684
-rwxr-xr-x 1 e4s e4s 6283264 Jul  7 15:50 jacamar
-rwxr-xr-x 1 e4s e4s 9773296 Jul  7 15:50 jacamar-auth
```

## Login Access

You can access Cori and Perlmutter, for more details see [Connecting to NERSC](https://docs.nersc.gov/connect/). If either system is down you can access data transfer nodes (`dtn[01-04].nersc.gov`) and then access the appropriate system. Please check out the NERSC MOTD at  https://www.nersc.gov/live-status/motd/ for live updates to system.

In order to access TDS systems like `muller` or `gerty` you will need to access one of the systems (cori, perlmutter, dtn) and then run the following:

```
ssh dtn01.nersc.gov
ssh gerty
```

It is probably a good idea to run `collabsu` or `usgrsu` once you are in the correct login node otherwise you may be prompted for a password for the `e4s` user.


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


