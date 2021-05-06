#!/bin/sh -e
echo starting start-openshift-nifi.sh
echo Path: $PWD

#useradd -u 1000160005 poduser

sudo chown -R :1000160005 /opt/nifi/

echo whoami:
myuser=$(whoami)
ehco I am: $myuser
myid=$(id)
echo my IDs are: $myid

echo Pre Nifi ID:
id nifi


#[ ! -f conf/nifi.properties ] && cp -a nifi-temp/conf .


ls -alR /opt/nifi

echo end
#echo kicking off start.sh
#su nifi

 ../scripts/start.sh
