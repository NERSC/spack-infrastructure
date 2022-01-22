# Contributing Guide

This guide will discuss how one can contribute back to this project. First, you will need to clone this repository locally. 

```
git clone https://software.nersc.gov/NERSC/spack-infrastructure.git
```

You will need to setup a [Personal Access Token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) in order to clone via HTTPS since git over ssh is disabled. 

The typical contribution process will be as follows:

```
git checkout -b <featureX>
git add <file1> <file2> ... <fileN>
git commit -m "COMMIT MESSAGE"
git push 
```

Please create a feature branch, add the files that need to be changed, commit and push your changes. Next [create a merge request](https://software.nersc.gov/NERSC/spack-infrastructure/-/merge_requests/new) to [main](https://software.nersc.gov/NERSC/spack-infrastructure/-/tree/main) branch. 

If you want to reproduce the steps in the CI, we encourage you review the [.gitlab-ci.yml](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/.gitlab-ci.yml) and run the instructions to recreate the environment.

Once you clone this repo locally, you can source the [setup-env.sh](https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/setup-env.sh) script. 

```
cd spack-infrastructure
source setup-env.sh
```

This script will create a python environment where you can perform spack builds. This script will set `CI_PROJECT_DIR` to root of spack-infrastructure project.

```
(spack-pyenv) siddiq90@login31> echo $CI_PROJECT_DIR
/global/homes/s/siddiq90/gitrepos/software.nersc.gov/spack-infrastructure
```

## Troubleshooting CI builds

First you will need to review the pipeline build in https://software.nersc.gov/NERSC/spack-infrastructure/-/pipelines and login as `e4s` user on the appropriate system. At top of pipeline you will see location where project was cloned typically this would be in **$CFS/m3503**. The content would look something like 
```
Reinitialized existing Git repository in /global/cfs/cdirs/m3503/ci/oGV2kxLA/0/NERSC/spack-infrastructure/.git/
```

You will need to navigate to the directory and then repeat the steps specified in `.gitlab-ci.yml` to reproduce the issue. 


