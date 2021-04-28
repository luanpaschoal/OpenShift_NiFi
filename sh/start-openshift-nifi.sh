#!/bin/sh -e
echo starting start-openshift-nifi.sh

[ ! -f conf/nifi.properties ] && cp -a nifi-1.11.4/conf .

[ ! -z $KUBERNETES_HEADLESS_SERVICE_NAME ] && HOSTNAME=$HOSTNAME.$KUBERNETES_HEADLESS_SERVICE_NAME

echo kicking off start.sh
../scripts/start.sh
