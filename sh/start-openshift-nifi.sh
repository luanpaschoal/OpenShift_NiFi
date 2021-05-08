#!/bin/sh -e
echo "####################################################################################"
echo "## Welcomes to a custom bash script to allow this image to run on OpenShift       ##"
echo "##                                                                                ##"
echo "## Please see: https://www.openshift.com/blog/a-guide-to-openshift-and-uids       ##"
echo "##             Under:TRADITIONAL APPLICATIONS AND UIDS                            ##"
echo "####################################################################################\n\n"

echo "I am"
whoami 
echo "let me fix a few things for you..."

echo "Copying conf DIR from nifi-temp/conf if nifi.properties is not in /opt/nifi/nifi-current nifi/conf DIR ..."
# see https://issues.apache.org/jira/browse/NIFI-6484
# see https://issues.apache.org/jira/browse/NIFI-6071
[ ! -f conf/nifi.properties ] && cp -a nifi-temp/conf .
echo "Done\n"

echo "Updating user 'nifi' with UID 1000160002 ..."
# create new user under OpenShift accepted group UID. "$ oc describe project [Project-Name]"
usermod -u 1000160002 nifi
echo "Done\n"

echo "Creating new group nifipodusers with GID 1000160001 ..."
# create a new group under Openshift accepted group GID. "$ oc describe project [Project-Name]"
groupadd -g 1000160001 nifipodusers
echo "Done\n"

echo "Adding user nifi to group nifipodusers ..."
# Add user nifi/poduser the group nifipodusers
usermod -a -G nifipodusers nifi
echo "Done\n"

echo "Giving ownership of all DIR's under /opt/nifi to group nifipodusers ..."
# Give group fill access to everything under /opt/nifi/
chgrp -R nifipodusers /opt/nifi
echo "Done\n"

echo "Cleaning up /opt/nifi so only group members and root have access ..."
# clean up access so only root and users under group nifipodusers have access
chmod -R 770 /opt/nifi
echo "Done\n"

echo "Setting user nifi home/work directory as /opt/nifi/nifi-current ..."
# set NiFi home directory
usermod -d /opt/nifi/nifi-current nifi
echo "Done\n"

echo "Did I login as nifi? ..."
#change to the new user
su - nifi
echo "I am:"
whoami  
echo "with id:"
id
echo "Done\n"

# List who owns DIR's inside of nifi
#ls -alR /opt/nifi
#ls -al

# Enable sleep to inspect the pod
#echo sleeping for 1 hour
#sleep 1h
#sleep 60


echo "current path ($PWD) should equal (/opt/nifi/nifi-current)\n\n"
ls -al
echo "kicking off NiFi's original ENTRYPOINT start.sh as user nifi"
../scripts/start.sh
