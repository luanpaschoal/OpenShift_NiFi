#!/bin/sh -e
echo starting start-openshift-nifi.sh
echo Path: $PWD

# if the nifi.properties does not exist then copy them over
[ ! -f conf/nifi.properties ] && cp -a nifi-temp/conf .


#ls -alR /opt/nifi

echo kicking off start.sh
#su nifi


../scripts/start.sh
