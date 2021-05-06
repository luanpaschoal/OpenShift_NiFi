#!/bin/sh -e
echo starting start-openshift-nifi.sh
echo Path: $PWD

echo whoami:
myuser=$(whoami)
ehco I am: $myuser
myid=$(id -g)
echo my ID is: $myid

echo Pre Nifi ID:
id nifi

usermod -a -G nifi $myuser

myid=$(id)
echo my ID are now: $myid

#[ ! -f conf/nifi.properties ] && cp -a nifi-temp/conf .


ls -alR /opt/nifi

echo end
#echo kicking off start.sh
#su nifi

# ../scripts/start.sh
