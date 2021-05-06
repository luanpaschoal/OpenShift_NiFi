#!/bin/sh -e
echo starting start-openshift-nifi.sh
echo Path: $PWD
echo Pre Nifi ID:

echo "Creating new user and group for nifi user"
# create new user under Openshift accepted group UID. "$ oc describe project [Project-Name]"
sudo useradd -u 1000160010 poduser
# create a new group under Openshift accepted group GID. "$ oc describe project [Project-Name]"
sudo groupadd -g 1000160001 nifipodusers

# copy the temp conf dir over if there is no nifi.properties
[ ! -f conf/nifi.properties ] && cp -a nifi-temp/conf .


# Add the docker user nifi and the new user to the group nifipodusers
sudo usermod -a -G nifipodusers nifi
sudo usermod -a -G nifipodusers poduser

# Give group fill access to everything under /opt/nifi/
sudo chown -R nifipodusers /opt/nifi
sudo chmod -R 770 /opt/nifi

#change to the new user
sudo su poduser

# Just test to see who is running
echo whoami:
myuser=$(whoami)
ehco I am: $myuser
myid=$(id)
echo my IDs are: $myid


# List who owns dir's inside of nifi
ls -alR /opt/nifi


echo kicking off start.sh

../scripts/start.sh
