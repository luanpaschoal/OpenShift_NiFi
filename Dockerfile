FROM apache/nifi:1.11.4

USER root
# Fix the permissions when running in OpenShift
RUN chmod -R a+rwx /opt/nifi
RUN find /opt/nifi -type f -iname "*.sh" -exec chmod +x {} \;

USER nifi
