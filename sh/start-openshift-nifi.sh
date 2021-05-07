#!/bin/sh -e
echo starting start-openshift-nifi.sh
echo Path: $PWD

echo "Copying over conf from temp if no conf/nifi.properties file"
[ ! -f conf/nifi.properties ] && cp -a nifi-temp/conf .
echo "conf copy done"

whoami
id

echo "Creating group and adding users poduser and nifi"
# create new user under Openshift accepted group UID. "$ oc describe project [Project-Name]"
useradd -u 1000160001 poduser

# create a new group under Openshift accepted group GID. "$ oc describe project [Project-Name]"
groupadd -g 1000160001 nifipodusers

# assign nif with a valid UID to run in Openshift
usermod -u 1000160002 nifi

# Add user nifi/poduser the group nifipodusers
usermod -a -G nifipodusers nifi
#usermod -a -G nifipodusers poduser

# Give group fill access to everything under /opt/nifi/
chgrp -R nifipodusers /opt/nifi

# clean up access so only root and users under group nifipodusers have access
chmod -R 770 /opt/nifi


#change to the new user
su nifi

# Just test to see who is running
whoami
id

# List who owns dir's inside of nifi
#ls -alR /opt/nifi
ls -al /opt/nifi


#echo sleeping for 1 hour
sleep 1h


echo Current Path: $PWD
ls -al
echo kicking off start.sh if its in the correct path
#../scripts/start.sh
