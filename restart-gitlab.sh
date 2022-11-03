#!/bin/bash
#export PATH=$PATH:$HOME/nersc-ecp-staff-runner/ecp-ci-0.6.1/gitlab-runner/out/binaries/

#set NERSC_HOST if it's not already set
if [ -z "$NERSC_HOST" ]; then
    if [ -e /etc/clustername ]; then
        export NERSC_HOST=`cat /etc/clustername`
    fi
fi

# hostname where gitlab runner should be running on
perlmutter_host='login27'
muller_host='login01'
cori_host='cori02'
gerty_host='gert01'

if [ "$NERSC_HOST" == "perlmutter" ]  && [ $(hostname) != "${perlmutter_host}" ]; then
    echo "Please run on ${perlmutter_host}"
    exit 1

elif [ "$NERSC_HOST" == "muller" ] && [ $(hostname) != "${muller_host}" ]; then
    echo "Please run on ${muller_host}"
    exit 1

elif [ "$NERSC_HOST" == "cori" ] && [ $(hostname) != "${cori_host}" ]; then
    echo "Please run on ${cori_host}"
    exit 1

elif [ "$NERSC_HOST" == "gerty" ] && [ $(hostname) != "${gerty_host}" ]; then
    echo "Please run on ${gerty_host}"
    exit 1
fi

configfile=$HOME/.gitlab-runner/$NERSC_HOST.config.toml


if [ ! -f $configfile ]; then
	echo "Unable to find gitlab configuration $configfile"
	exit 1
fi

pid=$(pgrep -u e4s gitlab-runner | wc -l)
if [[ $pid -lt 1 ]]
then
	screen -dmS $NERSC_HOST gitlab-runner run -c $configfile
	pid=$(pgrep -u e4s gitlab-runner)
	echo "Gitlab runner has started with ${pid}"
	curl -X POST --data-urlencode "payload={\"channel\": \"#spack-infrastructure\", \"username\": \"webhookbot\", \"text\": \"Restarting E4S runner on ${NERSC_HOST} at node: ${desired_host}. \", \"icon_emoji\": \":ghost:\"}" $SLACK_WEBHOOK
fi
