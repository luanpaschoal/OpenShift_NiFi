#!/bin/sh -e
echo starting start-openshift-nifi.sh
echo Path: $PWD

echo Pre Nifi ID:
id nifi


#[ ! -f conf/nifi.properties ] && cp -a nifi-temp/conf .


ls -alR /opt/nifi

echo end
#echo kicking off start.sh
#su nifi

# ../scripts/start.sh
