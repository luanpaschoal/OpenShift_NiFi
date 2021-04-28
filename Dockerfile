FROM apache/nifi:1.11.4

# Fix the permissions when running in OpenShift
RUN chmod -R a+rwx /opt/nifi/nifi-current
