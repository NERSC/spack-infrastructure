.. This page is designed to hold documentation for administering the Spack deployment of E4S




Administration Guide
====================

This page holds documentation for the processes that support the development, deployment
and continuous integration activities of Spack infrastructure at NERSC.




Troubleshooting GitLab Runner
-----------------------------

The `e4s` user is a `collaboration account <https://docs.nersc.gov/accounts/collaboration_accounts/>`_ which is a shared account used for spack
deployments. You will need to login as ``e4s`` user via  ``usgrsu`` command or use ``sshproxy`` to get 24hr credential and then **ssh** as the collaboration account.
This will prompt you for a password which is your **NERSC password** for your
username not **e4s** user. Note that ``collabsu`` is not present on Perlmutter
so you must use ``usgrsu`` to switch user accounts.

Once you are logged in, you can login to the desired system to restart the
runner. You can check the runner status by navigating to
`Settings > CI/CD > Runners <https://software.nersc.gov/NERSC/spack-infrastructure/-/settings/ci_cd>`_.
If the GitLab runner is down you will need to restart the runner. To check the status of the runner you 
can do the following, if you see the following message this means the runner is active and running.


.. code-block:: console

   ● perlmutter-e4s.service - Gitlab runner for e4s runner on perlmutter
     Loaded: loaded (/global/homes/e/e4s/.config/systemd/user/perlmutter-e4s.service; enabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-06-05 10:36:39 PDT; 23h ago
   Main PID: 140477 (gitlab-runner)
      Tasks: 47 (limit: 39321)
     Memory: 11.9G
        CPU: 1d 5h 43min 43.685s
     CGroup: /user.slice/user-93315.slice/user@93315.service/app.slice/perlmutter-e4s.service
             └─ 140477 /global/homes/e/e4s/jacamar/gitlab-runner run -c /global/homes/e/e4s/.gitlab-runner/perlmutter.config.toml

If the runner is not active you can restart this by running

```
systemctl --user restart perlmutter-e4s
```


The systemd service files are used for managing the gitlab runners. These files are the following

.. code-block:: console

   (spack-pyenv) e4s:login22> ls -l ~/.config/systemd/user/*.service
   -rw-rw-r-- 1 e4s e4s 326 May  9 07:32 /global/homes/e/e4s/.config/systemd/user/muller-e4s.service
   -rw-rw-r-- 1 e4s e4s 334 May  9 07:30 /global/homes/e/e4s/.config/systemd/user/perlmutter-e4s.service


The ``gitlab-runner`` command should be accessible via the e4s user. To register
a runner you can run ``gitlab-runner register`` and follow the prompt. The runner
configuration will be written to ``~/.gitlab-runner/config.toml``. However we
recommend you create a separate ``config.toml`` or copy the file to separate
location. For instance if you want to register a runner for muller you can set
``gitlab-runner register -c ~/.gitlab-runner/muller.config.toml`` when registering
the runner and it will write the runner configuration to
``~/.gitlab-runner/muller.config.toml``. For more details regarding runner
registration please see https://docs.gitlab.com/runner/register/.

Sometimes you may see unexpected results during CI jobs if you made changes to
the GitLab configuration and you have multiple GitLab-runner processes running
on different nodes. Therefore, we recommend you use ``pdsh`` to search for all
process across all nodes to find the process and then terminate it. The command below will search 
for the gitlab-runner process for service `perlmutter-e4s` across all Perlmutter login nodes. 

.. code-block::

   pdsh -w login[01-40] systemctl --user status perlmutter-e4s 2>&1 < /dev/null

Jacamar
-------

The GitLab runnners are using `Jacamar CI <https://gitlab.com/ecp-ci/jacamar-ci>`_,
there should be a ``jacamar.toml`` file in the following location:

.. code-block::

   e4s:login27> ls -l ~/.gitlab-runner/jacamar.toml
   -rw-rw-r-- 1 e4s e4s 758 Aug 11 08:57 /global/homes/e/e4s/.gitlab-runner/jacamar.toml


Any updates to the Jacamar configuration are applied to runner and there is no
need to restart GitLab runner.


The binaries ``jacamar`` and ``jacamar-auth`` are located in the following
location, if we need to upgrade Jacamar we should place them in this location,

.. code-block::

   e4s:login27> ls -l ~/jacamar/binaries/
   total 15684
   -rwxr-xr-x 1 e4s e4s 6283264 Jul  7 15:50 jacamar
   -rwxr-xr-x 1 e4s e4s 9773296 Jul  7 15:50 jacamar-auth


Login Access
------------

You can access Cori and Perlmutter, for more details see `Connecting to NERSC <https://docs.nersc.gov/connect/>`_.
If either system is down you can access data transfer nodes (``dtn[01-04].nersc.gov``)
and then access the appropriate system. Please check out the NERSC MOTD at
https://www.nersc.gov/live-status/motd/ for live updates to system.

In order to access TDS systems like ``muller`` or ``gerty`` you will need to
access one of the systems (cori, perlmutter, dtn) and then run the following:

.. code-block::

   ssh dtn01.nersc.gov
   ssh gerty


It is probably a good idea to run ``collabsu`` or ``usgrsu`` once you are in the
correct login node otherwise you may be prompted for a password for the ``e4s``
user.


Test for NERSC System Changes
-----------------------------

NERSC uses ReFrame to test system health after maintenance. In order to ensure the earliest possible notification
of system changes that will affect E4S builds, a test has been added. This test can be found at 
https://gitlab.nersc.gov/nersc/consulting/reframe-at-nersc/reframe-nersc-tests.


