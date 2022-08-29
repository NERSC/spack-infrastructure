.. This page is designed to hold documentation for administering the Spack deployment of E4S




Administration Documentation
============================

This page holds documentation for the processes that support the development, deployment
and continuous integration activities of Spack infrastructure at NERSC.



Slack Webhook
-------------

The `restart-gitlab.sh <https://software.nersc.gov/NERSC/spack-infrastructure/-/blob/main/restart-gitlab.sh>`_
is responsible for restarting gitlab and sending slack notification to NERSC
Slack at **#spack-infrastructure**.  This action requires a Webhook URL which must
be saved as a secret. The secret is called ``SLACK_WEBHOOK`` which can be updated
at https://software.nersc.gov/NERSC/spack-infrastructure/-/settings/ci_cd.
