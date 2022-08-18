#!/bin/bash
#export PATH=$PATH:$HOME/nersc-ecp-staff-runner/ecp-ci-0.6.1/gitlab-runner/out/binaries/

#set NERSC_HOST if it's not already set
if [ -z "$NERSC_HOST" ]; then
    if [ -e /etc/clustername ]; then
        export NERSC_HOST=`cat /etc/clustername`
    fi
fi

if [ "$NERSC_HOST" == "perlmutter" ]; then
	desired_host="login27"
elif [ "$NERSC_HOST" == "muller" ]; then
	desired_host="login02"
elif [ "$NERSC_HOST" == "cori" ]; then
	desired_host="cori02"
elif [ "$NERSC_HOST" == "gerty" ]; then
	desired_host="gert01"
fi

configfile=$HOME/.gitlab-runner/$NERSC_HOST.config.toml

if [[ $(hostname) != "$desired_host" ]]
then
	echo "Please run this script from $desired_host"
	exit 1
fi

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
	mail -s "restart e4s runner on $NERSC_HOST" shahzebsiddiqui@lbl.gov <<< "restarting e4s runner on $NERSC_HOST"
    curl -X POST --data-urlencode "payload={\"channel\": \"#spack-infrastructure\", \
                                            \"username\": \"incoming-webhook\", \
                                            \"text\": \"Restarting E4S runner on ${NERSC_HOST}.\"}" \
                                            https://hooks.slack.com/services/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
fi
