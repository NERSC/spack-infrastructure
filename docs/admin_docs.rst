.. This page is designed to hold documentation for administering the Spack deployment of E4S




Administration Guide
====================

This page holds documentation for the processes that support the development, deployment
and continuous integration activities of Spack infrastructure at NERSC.


Login Access
------------

You can access Perlmutter, for more details see `Connecting to NERSC <https://docs.nersc.gov/connect/>`_.
If system is down you can access data transfer nodes (``dtn[01-04].nersc.gov``) or muller
and then access the appropriate system. Please check out the NERSC MOTD at
https://www.nersc.gov/live-status/motd/ for live updates to system.

In order to access TDS systems like ``muller`` you will need to
access one of the systems (dtn) and then run the following:

.. code-block:: 

   ssh dtn01.nersc.gov
   ssh login.muller.nersc.gov

Alternately, you can add the following configuration in your `~/.ssh/config` which allows you to access muller easily and ProxyJump from one of the data transfer nodes 
automatically.

.. code-block::

   Host muller
     Hostname login.muller.nersc.gov
     ProxyJump dtn

   Host muller01
      Hostname login01.chn.muller.nersc.gov
      ProxyJump dtn01

   Host muller02
      Hostname login02.chn.muller.nersc.gov
      ProxyJump dtn01   

From your laptop, you just need to run `ssh muller` or `ssh muller01` or `ssh muller02` if you want to access a particular login node. 


The ``e4s`` user is a `collaboration account <https://docs.nersc.gov/accounts/collaboration_accounts/>`_ which is a shared account used for spack
deployments. You will need to login as ``e4s`` user using ``sshproxy`` to get 24hr credential and then **ssh** as the collaboration account.
This will prompt you for a password which is your **NERSC password** for your username not **e4s** user. 

Only members part of `c_e4s` unix group have access to use the collaboration account. You can run the following to see list of users that belong to the group. If you don't belong to this group and should be 
part of this group, please send a ticket at https://help.nersc.gov 

.. code-block::

   getent group c_e4s


Production Software Stack
---------------------------

The spack stack is installed on shared filesystem at ``/global/common/software/spackecp``. The project space has a quota limit for space and inode count. To check for the quota space please run the following

.. code-block::

   cfsquota /global/common/software/spackecp

The production installation of e4s stack on Perlmutter is stored in sub-directory `perlmutter` with a version for each stack as follows

.. code-block:: console

   (spack-pyenv) e4s:login22> ls -ld /global/common/software/spackecp/perlmutter/e4s-*
   drwxrwsr-x+ 8 e4s spackecp 512 Jun  6 10:09 /global/common/software/spackecp/perlmutter/e4s-21.11
   drwxrwsr-x+ 9 e4s spackecp 512 Jan 12 07:34 /global/common/software/spackecp/perlmutter/e4s-22.05
   drwxrwsr-x+ 5 e4s spackecp 512 Mar 28 10:24 /global/common/software/spackecp/perlmutter/e4s-22.11

Within the installation you will see several subdirectories which contain a unique identified from the CI job. The `default` is a symbolic link to the active production stack

.. code-block:: console 

   (spack-pyenv) e4s:login22> ls -l /global/common/software/spackecp/perlmutter/e4s-22.11/
   total 4
   drwxrwsr-x+ 3 e4s spackecp 512 Mar  6 14:40 82028
   drwxrwsr-x+ 3 e4s spackecp 512 Mar 28 10:16 82069
   drwxrwsr-x+ 3 e4s spackecp 512 Mar 28 08:34 83104
   lrwxrwxrwx  1 e4s spackecp   5 Mar 28 10:24 default -> 83104

We have one modulefile per e4s stack, they are named as ``e4s/<version>`` with a symobolic link ``spack/e4s-<version>``. In the modulefile you will see path to root installation of spack.
As we can see from example below, the root of spack is located in ``/global/common/software/spackecp/perlmutter/e4s-22.11/default/spack``

.. code-block:: console

   (spack-pyenv) e4s:login22> module --redirect --raw show e4s/22.11 | grep root
   local root = "/global/common/software/spackecp/perlmutter/e4s-22.11/default/spack"
            spack_setup = pathJoin(root, "share/spack/setup-env.sh")
            spack_setup = pathJoin(root, "share/spack/setup-env.csh")
            spack_setup = pathJoin(root, "share/spack/setup-env.fish")
      remove_path("PATH", pathJoin(root, "bin"))

   (spack-pyenv) e4s:login22> ls -l /global/common/software/spackecp/perlmutter/e4s-22.11/default/spack
   total 100
   drwxrwsr-x+ 2 e4s spackecp   512 Mar 28 08:54 bin
   -rw-rw-r--  1 e4s spackecp 55695 Mar 28 08:35 CHANGELOG.md
   -rw-rw-r--  1 e4s spackecp  1941 Mar 28 08:35 CITATION.cff
   -rw-rw-r--  1 e4s spackecp  3262 Mar 28 08:35 COPYRIGHT
   drwxrwsr-x+ 3 e4s spackecp   512 Mar 28 08:35 etc
   drwxrwsr-x+ 3 e4s spackecp   512 Mar 28 08:35 lib
   -rw-rw-r--  1 e4s spackecp 11358 Mar 28 08:35 LICENSE-APACHE
   -rw-rw-r--  1 e4s spackecp  1107 Mar 28 08:35 LICENSE-MIT
   -rw-rw-r--  1 e4s spackecp  1167 Mar 28 08:35 NOTICE
   drwxrwsr-x+ 3 e4s spackecp   512 Mar 28 08:35 opt
   -rw-rw-r--  1 e4s spackecp  2946 Mar 28 08:35 pyproject.toml
   -rw-rw-r--  1 e4s spackecp   764 Mar 28 08:35 pytest.ini
   -rw-rw-r--  1 e4s spackecp  6522 Mar 28 08:35 README.md
   -rw-rw-r--  1 e4s spackecp   699 Mar 28 08:35 SECURITY.md
   drwxrwsr-x+ 3 e4s spackecp   512 Mar 28 08:35 share
   drwxrwsr-x+ 3 e4s spackecp   512 Mar 28 08:35 var


Changing Production stack within a release
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To change the production path you will need to change the `default` symbolic link to the latest run. First navigate to the directory where you have the production installation. For example, lets change to the root of `e4s-22.11` 
and remove the symbolic link

.. code-block::

   cd  /global/common/software/spackecp/perlmutter/e4s-22.11/
   unlink default


Next create a symbolic link to the new directory 

.. code-block::

   ln -s <DIRECTORY_ID> default


Troubleshooting GitLab Runner
-----------------------------

The gitlab runner is registered on node `login07` on Perlmutter. You can check the runner status by navigating to
`Settings > CI/CD > Runners <https://gitlab.nersc.gov/nersc/pem/spack-infrastructure/-/settings/ci_cd>`_.
If the GitLab runner is down you will need to restart the runner. To check the status of the runner you 
can run:


.. code-block:: console

   e4s:login07> systemctl --user status perlmutter-login07
   ● perlmutter-login07.service - Gitlab runner for e4s runner on perlmutter
      Loaded: loaded (/global/homes/e/e4s/.config/systemd/user/perlmutter-login07.service; enabled; vendor preset: disabled)
      Active: active (running) since Wed 2024-12-18 22:14:10 PST; 1 week 1 day ago
      Main PID: 173520 (gitlab-runner)
         Tasks: 90 (limit: 353894)
      Memory: 39.0M
         CPU: 6h 52min 14.381s
      CGroup: /user.slice/user-93315.slice/user@93315.service/app.slice/perlmutter-login07.service
               └─ 173520 /global/homes/e/e4s/jacamar/gitlab-runner run -c /global/homes/e/e4s/.gitlab-runner/perlmutter-login07.config.toml

If the runner is not active you can restart this by running

.. code-block::

   systemctl --user restart perlmutter-login07

You can view the systemd service file by running, where you will see the `gitlab-runner` command used for starting the gitlab runner.

.. code-block::

   e4s:login07> systemctl --user cat perlmutter-login07
   # /global/homes/e/e4s/.config/systemd/user/perlmutter-login07.service
   [Unit]
   Description=Gitlab runner for e4s runner on perlmutter
   ConditionHost=login07

   [Service]
   ExecStart=/global/homes/e/e4s/jacamar/gitlab-runner run -c /global/homes/e/e4s/.gitlab-runner/perlmutter-login07.config.toml
   Restart=on-failure
   RestartSec=120
   StartLimitInterval=10min
   StartLimitBurst=5

   [Install]
   WantedBy=default.target

The systemd service files are used for starting the gitlab-runner, shown below are the files for reference. 

.. code-block:: console

   (spack-pyenv) e4s:login22> ls -l ~/.config/systemd/user/*.service
   -rw-rw-r-- 1 e4s e4s 317 Jun 27  2023 /global/homes/e/e4s/.config/systemd/user/muller-e4s.service
   -rw-rw-r-- 1 e4s e4s 334 Jul 19  2023 /global/homes/e/e4s/.config/systemd/user/perlmutter-login07.service


If you want to update these files, please make sure you stop, reload and start the the systemD service. The commands to be run are 

.. code-block:: console

   systemctl --user stop perlmutter-login07

   systemctl --user daemon-reload
   
   systemctl --user start perlmutter-login07

   

The ``gitlab-runner`` command should be accessible via the e4s user. To register
a runner you can run ``gitlab-runner register`` and follow the prompt. The runner
configuration will be written to ``~/.gitlab-runner/config.toml``. However we
recommend you create a separate ``config.toml`` or copy the file to separate
location. For instance if you want to register a runner for muller you can set
``gitlab-runner register -c ~/.gitlab-runner/muller.config.toml`` when registering
the runner and it will write the runner configuration to
``~/.gitlab-runner/muller.config.toml``. For more details regarding runner
registration please see https://docs.gitlab.com/runner/register/.

Jacamar
-------

The GitLab runnners are using `Jacamar CI <https://gitlab.com/ecp-ci/jacamar-ci>`_,
there should be a ``jacamar.toml`` file in the following location:

.. code-block:: console

   e4s:login27> ls -l ~/.gitlab-runner/jacamar.toml
   -rw-rw-r-- 1 e4s e4s 758 Aug 11 08:57 /global/homes/e/e4s/.gitlab-runner/jacamar.toml


Any updates to the Jacamar configuration are applied to runner and there is no
need to restart GitLab runner.


The binaries ``jacamar`` and ``jacamar-auth`` are located in the following
location, if we need to upgrade Jacamar we should place them in this location,

.. code-block:: console

   e4s:login27> ls -l ~/jacamar/binaries/
   total 15684
   -rwxr-xr-x 1 e4s e4s 6283264 Jul  7 15:50 jacamar
   -rwxr-xr-x 1 e4s e4s 9773296 Jul  7 15:50 jacamar-auth


Test for NERSC System Changes
-----------------------------

NERSC uses ReFrame to test system health after maintenance. In order to ensure the earliest possible notification
of system changes that will affect E4S builds, a test has been added. This test can be found at 
https://gitlab.nersc.gov/nersc/consulting/reframe-at-nersc/reframe-nersc-tests.


