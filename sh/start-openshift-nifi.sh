#!/bin/sh -e
echo starting start-openshift-nifi.sh
echo Path: $PWD
#[ ! -f conf/nifi.properties ] && cp -a nifi-1.11.4/conf .

[ ! -z $KUBERNETES_HEADLESS_SERVICE_NAME ] && HOSTNAME=$HOSTNAME.$KUBERNETES_HEADLESS_SERVICE_NAME
ls -alR /opt/nifi

echo kicking off start.sh
su nifi
../scripts/start.sh
