# How To Guide

## How to setup a schedule pipeline

First go to `CI/CD > Schedules <https://software.nersc.gov/NERSC/spack-infrastructure/-/pipeline_schedules>` and create a schedule pipeline. You should see a similar pipeline for another stack.
The schedule pipeline contains a unique variable `PIPELINE_NAME` which is the name of E4S stack to run. The value is all CAPS, so if you want to trigger E4S 23.05 stack for Perlmutter, the value 
will be `PERLMUTTER_E4S_23.05`. Please make sure the variable `PIPELINE_NAME` matches the one you defined in `.gitlab-ci.yml <https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/.gitlab-ci.yml>`_ 
for your job. The pipeline can be run via `web interface <https://software.nersc.gov/NERSC/spack-infrastructure/-/pipelines/new>`_, if you chose this route, just set `PIPELINE_NAME` to the appropriate value.

The reason why we setup schedule pipeline and web-interface is to allow one to trigger pipeline automatically at schedule interval or trigger pipeline manually such that a commit is not required
to trigger pipeline. This is useful when one needs to check if pipeline can rebuild at any given time due to system change.

## How to find available runners

 You can find all runners by going to `Settings > CI/CD > Runners <https://software.nersc.gov/NERSC/spack-infrastructure/-/settings/ci_cd>`_. 
 

This project is configured with gitlab runner for Perlmutter and Muller using the production account `e4s`. Shown below are the available runners 

.. list-table:: Gitlab Runner by NERSC system
   :widths: 25 25 
   :header-rows: 1

   * - System, Runner Name
     - Perlmutter, `perlmutter-e4s``
     - Muller, `muller-e4s`


The runner configuration files are located in directory `~/.gitlab-runner` for user **e4s**.

## How to register gitlab runner

We have a script titled `register.sh` that is responsible for registering a gitlab runner. This script will expect a registration token which can be found at 
`Settings > CI/CD > Runners <https://software.nersc.gov/NERSC/spack-infrastructure/-/settings/ci_cd>`_.  Shown below is the script used to register the runner on Perlmutter,
once you execute the script, you will be prompted for the registration token.


.. code-block:: console

    e4s:login37> cat ~/register.sh
    #!/bin/bash

    read -sp "Registration Token?" TOKEN
    gitlab-runner register \
        --url https://software.nersc.gov \
        --registration-token ${TOKEN} \
            --tag-list ${NERSC_HOST}-${USER} \
        --name "E4S Runner on Perlmutter" \
        --executor custom \
        --custom-config-exec "/global/homes/e/e4s/jacamar/binaries/jacamar-auth" \
        --custom-config-args "-u config --configuration /global/homes/e/e4s/.gitlab-runner/jacamar.toml" \
        --custom-prepare-exec "/global/homes/e/e4s/jacamar/binaries/jacamar-auth" \
        --custom-prepare-args "prepare" \
        --custom-run-exec  "/global/homes/e/e4s/jacamar/binaries/jacamar-auth" \
        --custom-run-args "run" \
        --custom-cleanup-exec "/global/homes/e/e4s/jacamar/binaries/jacamar-auth" \
        --custom-cleanup-args "cleanup --configuration /global/homes/e/e4s/.gitlab-runner/jacamar.toml" \
        --config /global/homes/e/e4s/.gitlab-runner/perlmutter.config.toml

