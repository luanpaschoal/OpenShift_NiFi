This image has been modified from https://github.com/apache/nifi.git
The following changes have been made to allow apache/nifi work perfectly with OpenShift
This makes a copy of the conf DIR, then copies it back once OpenShift creates a persistent volume.
    More info: https://issues.apache.org/jira/browse/NIFI-6484
We have also allowed docker to create this image as root and not let user 'nifi' have any involvement
