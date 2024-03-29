# Spack Infrastructure

The Spack Infrastructure Project makes use of [spack package manager](https://spack.readthedocs.io/en/latest/) to install spack software stack on NERSC systems. This project contains spack configuration (`spack.yaml`) required to build the spack stacks. The spack stack is based on [Extreme-Scale Scientific Software Stack](https://e4s.io/) (E4S) where we install spack packages provided by E4S and use the recommended spack branch. We leverage [Gitlab CI](https://docs.gitlab.com/ee/ci/) to automate deployment to ensure reproducible and automated builds. For more details about this project you can see the documentation at [https://nersc-spack-infrastructure.rtfd.io](https://nersc-spack-infrastructure.rtfd.io)

## Software Deployment Overview

The software deployment consist of the following steps

1. Acquire Spack Configuration from E4S project [https://github.com/E4S-Project/e4s](https://github.com/E4S-Project/e4s) 
2. Create one or more spack configuration files (spack.yaml) with list of E4S packages and integrate spack configuration for NERSC system
3. Create a Gitlab Job to trigger the pipeline for TDS and Deployment system
4. Create a Modulefile as entry point to stack
5. Write User Documentation
6. Share spack configuration with open-source community
7. Send announcement to all NERSC users

### Step 1: Acquire Spack Configuration

At NERSC, we plan our software deployment with E4S releases which is typically every 3 months however we perform deployment every 6 months. Once E4S has released the spack configuration we acquire the spack configuration which is typically found in [https://github.com/E4S-Project/e4s/tree/master/environments](https://github.com/E4S-Project/e4s/tree/master/environments). We also acquire the spack [branch](https://github.com/spack/spack/branches) used by E4S team as our baseline, this would be documented in the release notes. The name of branch map to the E4S version so version 23.05 will have a branch [e4s-23.05](https://github.com/spack/spack/tree/e4s-23.05).

Next, we copy the packages into our project and create the spack configuration

### Step 2: Create Spack Configuration

In this step we create the spack configuration. First we create a sub-directory in *spack-configs* with the naming convention to distinguish E4S version. This typically includes the 
name of the system such as `cori` or `perlmutter` followed by name of e4s version such as `e4s-23.05`. 

```console
$ tree -L 1 spack-configs
spack-configs
├── cori-e4s-20.10
├── cori-e4s-21.02
├── cori-e4s-21.05
├── cori-e4s-22.02
├── perlmutter-e4s-21.11
├── perlmutter-e4s-22.05
├── perlmutter-e4s-22.11
├── perlmutter-e4s-23.05
├── perlmutter-spack-develop
└── perlmutter-user-spack

10 directories, 0 files
```

Inside one of the stacks, you will see several sub-directories that are used for defining a sub-stack. These sub-stacks correspond to [spack environments](https://spack.readthedocs.io/en/latest/environments.html). The `prod` directory is used for production deployment to install from the buildcache.

```console
$ tree -L 3 spack-configs/perlmutter-e4s-22.11
spack-configs/perlmutter-e4s-22.11
├── cce
│   └── spack.yaml
├── cuda
│   └── spack.yaml
├── definitions.yaml
├── gcc
│   └── spack.yaml
├── nvhpc
│   └── spack.yaml
└── prod
    ├── cce
    │   └── spack.yaml
    ├── cuda
    │   └── spack.yaml
    ├── gcc
    │   └── spack.yaml
    └── nvhpc
        └── spack.yaml

9 directories, 9 files
```

We create a special file named `definitions.yaml` that is used for declaring definitions that is referenced in `spack.yaml`. This file is appended to all spack configuration. We do this
to ensure all specs are defined in one place.

During this step, we will create the spack configuration and specify our preferred compilers and package preference. We install software in buildcache so it can be relocated to production path. In order to accomplish this task, we use [spack pipelines](https://spack.readthedocs.io/en/latest/pipelines.html) that uses `spack ci generate` and `spack ci rebuild` to perform parallel pipeline execution. During this step, we determine which packages to install from E4S and add our own packages to comply with our site preference. 

### Step 3: Create Gitlab Job for Automation

Once spack configuration is written, we create a gitlab job to trigger the pipeline. This can be done by specifying a job in [.gitlab-ci.yml](https://github.com/NERSC/spack-infrastructure/blob/main/.gitlab-ci.yml). 

The gitlab job can be triggered through [scheduled pipelines](https://software.nersc.gov/NERSC/spack-infrastructure/-/pipeline_schedules), [web-interface](https://software.nersc.gov/NERSC/spack-infrastructure/-/pipelines/new), or merge request to the project. A typical gitlab job will look something like this. Shown below is for E4S 23.05 generate job. We make use of gitlab feature named [extends](https://docs.gitlab.com/ee/ci/yaml/index.html#extends) which allows us to reuse configuration. The `spack ci generate` command will be the same for each substack. There is two jobs, first is the generate step performed by `spack ci generate` and this triggers the downstream job created by spack.



```yaml
.perlmutter-e4s-23.05-generate:
  stage: generate
  needs: ["perlmutter:check_spack_dependencies"]
  tags: [perlmutter-e4s]
  interruptible: true
  allow_failure: true
  rules:
    - if: ($CI_PIPELINE_SOURCE == "schedule" || $CI_PIPELINE_SOURCE == "web") && ($PIPELINE_NAME == "PERLMUTTER_E4S_23.05")
    - if: ($CI_PIPELINE_SOURCE == "merge_request_event")
      changes:
      - spack-configs/perlmutter-e4s-23.05/$STACK_NAME/spack.yaml
      - spack-configs/perlmutter-e4s-23.05/definitions.yaml
  before_script:
    - *copy_perlmutter_settings
    - *startup_modules
  script:
    - *e4s_23_05_setup 
    - cd $CI_PROJECT_DIR/spack-configs/perlmutter-e4s-23.05/$STACK_NAME
    - cat $CI_PROJECT_DIR/spack-configs/perlmutter-e4s-23.05/definitions.yaml >> spack.yaml
    - spack env activate --without-view  .
    - spack env st
    #- spack -d concretize -f | tee $CI_PROJECT_DIR/concretize.log    
    - spack -d ci generate --check-index-only --artifacts-root "$CI_PROJECT_DIR/jobs_scratch_dir" --output-file "${CI_PROJECT_DIR}/jobs_scratch_dir/pipeline.yml"
  artifacts: 
    paths:
    - ${CI_PROJECT_DIR}/jobs_scratch_dir


perlmutter-e4s-23.05-cce-generate:
  extends: .perlmutter-e4s-23.05-generate
  variables:
    STACK_NAME: cce

perlmutter-e4s-23.05-cce-build:
  stage: build
  needs: ["perlmutter:check_spack_dependencies", "perlmutter-e4s-23.05-cce-generate"]
  allow_failure: true
  rules:
    - if: ($CI_PIPELINE_SOURCE == "schedule" || $CI_PIPELINE_SOURCE == "web") && ($PIPELINE_NAME == "PERLMUTTER_E4S_23.05")
    - if: ($CI_PIPELINE_SOURCE == "merge_request_event")
      changes:
      - spack-configs/perlmutter-e4s-23.05/cce/spack.yaml
      - spack-configs/perlmutter-e4s-23.05/definitions.yaml
  trigger:
    include:
      - artifact: jobs_scratch_dir/pipeline.yml
        job: perlmutter-e4s-23.05-cce-generate
    strategy: depend
```

### Step 4: Create Modulefile 

In this step, we create a modulefile as entry point to software stack and setup `spack`. We do not create spack generated modules for spack packages, instead one is expected to use `spack load`.  Shown below are the modulefiles available on NERSC system, they are typically called `e4s/<version>` with a symbolic link to module `spack/e4s-<version>` 


```console
siddiq90@login37> ml -t av e4s
/global/common/software/nersc/pm-2022.12.0/extra_modulefiles:
e4s/22.05
e4s/22.11
spack/e4s-22.05
spack/e4s-22.11
```

Shown below is the content of our modulefile, the setup is subject to change

```console
siddiq90@login37> ml --raw show e4s
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   /global/common/software/nersc/pm-2022.12.0/extra_modulefiles/e4s/22.11.lua:
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
whatis([[
        The Extreme-scale Scientific Software Stack (E4S) is a collection of open source software packages for running scientific applications on high-performance computing (HPC) platforms.
        ]])
help([[ The Extreme-scale Scientific Software Stack (E4S) is a community effort to provide open source software packages for developing, deploying and running scientific applications on high-performance computing (HPC) platforms. E4S provides from-source builds and containers of a broad collection of HPC software packages.

References:
  - E4S User Docs: https://e4s.readthedocs.io/en/latest/index.html
  - E4S 22.11 Docs: https://docs.nersc.gov/applications/e4s/perlmutter/22.11/
  - E4S Homepage: https://e4s-project.github.io/
  - E4S GitHub: https://github.com/E4S-Project/e4s
        ]])

local root = "/global/common/software/spackecp/perlmutter/e4s-22.11/default/spack"

setenv("SPACK_GNUPGHOME", pathJoin(os.getenv("HOME"), ".gnupg"))
setenv("SPACK_SYSTEM_CONFIG_PATH", "/global/common/software/spackecp/perlmutter/spack_settings")
-- setup spack shell functionality
local shell = myShellType()
if (mode() == "load") then
    local spack_setup = ''
    if (shell == "sh" or shell == "bash" or shell == "zsh") then
         spack_setup = pathJoin(root, "share/spack/setup-env.sh")
    elseif (shell == "csh") then
         spack_setup = pathJoin(root, "share/spack/setup-env.csh")
    elseif (shell == "fish")  then
         spack_setup = pathJoin(root, "share/spack/setup-env.fish")
    end

    -- If we are unable to find spack setup script let's terminate now.
    if not isFile(spack_setup) then
        LmodError("Unable to find spack setup script " .. spack_setup .. "\n")
    end

    execute{cmd="source " .. spack_setup, modeA={"load"}}

    LmodMessage([[
    _______________________________________________________________________________________________________
     The Extreme-Scale Scientific Software Stack (E4S) is accessible via the Spack package manager.

     In order to access the production stack, you will need to load a spack environment. Here are some tips to get started:


     'spack env list' - List all Spack environments
     'spack env activate gcc' - Activate the "gcc" Spack environment
     'spack env status' - Display the active Spack environment
     'spack load amrex' - Load the "amrex" Spack package into your user environment

     For additional support, please refer to the following references:

       NERSC E4S Documentation: https://docs.nersc.gov/applications/e4s/
       E4S Documentation: https://e4s.readthedocs.io
       Spack Documentation: https://spack.readthedocs.io/en/latest/
       Spack Slack: https://spackpm.slack.com

    ______________________________________________________________________________________________________
    ]])
-- To remove spack from shell we need to remove a few environment variables, alias and remove $SPACK_ROOT/bin from $PATH
elseif (mode() == "unload" or mode() == "purge") then
    if (shell == "sh" or shell == "bash" or shell == "zsh") then
      execute{cmd="unset SPACK_ENV",modeA={"unload"}}
      execute{cmd="unset SPACK_ROOT",modeA={"unload"}}
      execute{cmd="unset -f spack",modeA={"unload"}}
    elseif (shell == "csh") then
      execute{cmd="unsetenv SPACK_ENV",modeA={"unload"}}
      execute{cmd="unsetenv SPACK_ROOT",modeA={"unload"}}
      execute{cmd="unalias spack",modeA={"unload"}}
    end

    -- Need to remove $SPACK_ROOT/bin from $PATH which removes the 'spack' command
    remove_path("PATH", pathJoin(root, "bin"))

    -- Remove alias spacktivate. Need to pipe to /dev/null as invalid alias can report error to stderr
    execute{cmd="unalias spacktivate > /dev/null",modeA={"unload"}}
end
```

### Step 5: User Documentation

User documentation is fundamental to help assist users with using E4S at NERSC. We document every E4S release with its *Release Date* and *End of Support* date along with a documentation page outlining the software stack. Our E4S documentation is available at [https://docs.nersc.gov/applications/e4s/](https://docs.nersc.gov/applications/e4s/). The release date is when documentation is live. We perform this action in conjunction with release of modulefile so that user gain access to software stack. 

Upon completion of this task, we are ready to make announcement to our NERSC users

### Step 6: Sharing spack configuration with open-source community

In this step, we share our spack configuration with open-source community that may benefit the wider community. We share our spack configuration at [https://github.com/spack/spack-configs](https://github.com/spack/spack-configs). In addition, we update the [E4S Facility Dashboard](https://e4s.readthedocs.io/en/latest/facility_e4s.html) that shows all the E4S deployments across all the facilities.

### Step 7: Public Announcement

This is the final step of the deployment process, where we make a public announcement in NERSC weekly email, along with various slack channels such as Nersc User Group (NUG), Spack, ECP and E4S slack. 




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

- Shahzeb Siddiqui - [shahzebsiddiqui@lbl.gov](mailto:shahzebsiddiqui@lbl.gov)
- Erik Palmer - [epalmer@lbl.gov](mailto:epalmer@lbl.gov)
- Justin Cook - [JSCook@lbl.gov](mailto:JSCook@lbl.gov)
- E4S Team: Sameer Shende ([sameer@cs.uoregon.edu](mailto:sameer@cs.uoregon.edu)), Christopher Peyralans ([lpeyrala@uoregon.edu](mailto:lpeyrala@uoregon.edu)), Wyatt Spear ([wspear@cs.uoregon.edu](mailto:wspear@cs.uoregon.edu)), Nicholas Chaimov ([nchaimov@paratools.com](mailto:nchaimov@paratools.com))


