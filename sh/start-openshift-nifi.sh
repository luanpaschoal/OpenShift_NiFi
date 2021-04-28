#!/bin/sh -e

[ ! -f conf/nifi.properties ] && cp -a nifi-1.11.4/conf .

[ ! -z $KUBERNETES_HEADLESS_SERVICE_NAME ] && HOSTNAME=$HOSTNAME.$KUBERNETES_HEADLESS_SERVICE_NAME

chmod -R a+rwx /opt/nifi
find /opt/nifi -type f -iname "*.sh" -exec chmod +x {} \;
ls
#RUN chmod +x /opt/nifi/scripts/toolkit.sh

su ../scripts/start.sh
