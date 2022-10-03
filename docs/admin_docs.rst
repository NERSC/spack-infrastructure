.. This page is designed to hold documentation for administering the Spack deployment of E4S




Administration Guide
====================

This page holds documentation for the processes that support the development, deployment
and continuous integration activities of Spack infrastructure at NERSC.




Troubleshooting GitLab Runner
-----------------------------

You will need to login as ``e4s`` user via ``collabsu`` or ``usgrsu`` command.
This will prompt you for a password which is your **NERSC password** for your
username not **e4s** user. Note that ``collabsu`` is not present on Perlmutter
so you must use ``usgrsu`` to switch user accounts.

.. code-block::

   collabsu e4s

Once you are logged in, you can login to the desired system to restart the
runner. You can check the runner status by navigating to
`Settings > CI/CD > Runners <https://software.nersc.gov/NERSC/spack-infrastructure/-/settings/ci_cd>`_.
If the GitLab runner is down you will need to restart the runner which is
located in ``$HOME/cron`` directory for the e4s user.


The ``gitlab-runner`` command should be accessible via the e4s user. To register
a runner you can run ``gitlab-runner register`` and follow the prompt. The runner
configuration will be written to ``~/.gitlab-runner/config.toml``. However we
recommend you create a separate ``config.toml`` or copy the file to separate
location. For instance if you want to register a runner for muller you can set
``gitlab-runner register -c ~/.gitlab-runner/muller.config.toml`` when registering
the runner and it will write the runner configuration to
``~/.gitlab-runner/muller.config.toml``. For more details regarding runner
registration please see https://docs.gitlab.com/runner/register/.

To restart a runner you can run the
`restart-gitlab.sh <https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/restart-gitlab.sh>`_
script which should be present in ``$HOME/cron``.


.. code-block::

   bash $HOME/cron/restart-gitlab.sh

You can check if the GitLab process is running via ``pgrep`` assuming you are on
the right node. Shown below is an example output, you should only see one GitLab
runner process running on a node.

.. code-block::

   e4s:login27> pgrep -a -u e4s gitlab-runner
   52769 gitlab-runner run -c /global/homes/e/e4s/.gitlab-runner/perlmutter.config.toml

Sometimes you may see unexpected results during CI jobs if you made changes to
the GitLab configuration and you have multiple GitLab-runner processes running
on different nodes. Therefore, we recommend you use ``pdsh`` to search for all
process across all nodes to find the process and then terminate it. For instance
you can run ``pgrep`` across all Cori login nodes (**cori01-12**) to find any
GitLab process, if you see multiple process then you can login to that
particular node and terminate the process.

.. code-block::

   pdsh -w cori[01-12] pgrep -a -u e4s gitlab-runner

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

Slack Webhook
-------------

The `restart-gitlab.sh <https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/restart-gitlab.sh>`_
is responsible for restarting gitlab and sending slack notification to NERSC
Slack at **#spack-infrastructure**.  This action uses Curl and requires a Webhook URL which must
be saved as a secret. The secret is called ``SLACK_WEBHOOK`` which can be updated
at https://software.nersc.gov/NERSC/spack-infrastructure/-/settings/ci_cd. The relevant command
is:

.. code-block::

   curl -X POST --data-urlencode "payload={\"channel\": \"#spack-infrastructure\", \"username\":
   \"webhookbot\", \"text\": \"Restarting E4S runner on ${NERSC_HOST} at node: ${desired_host}. \",
   \"icon_emoji\": \":ghost:\"}" $SLACK_WEBHOOK


Test for NERSC System Changes
-----------------------------

NERSC uses ReFrame to test system health after maintenance. In order to ensure the earliest possible notification
of system changes that will affect E4S builds, a test has been added. See
<https://gitlab.nersc.gov/nersc/consulting/reframe-at-nersc/reframe-nersc-tests>`_.
Currently, the test consists of only the  script `check_spack_dependencies.sh`.


