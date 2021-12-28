## The following has been modified from https://github.com/apache/nifi.git
# The following changes have been made to allow apache/nifi work perfectly with OpenShift
# This makes a copy of the conf DIR, then copies it back once OpenShift creates a persistent volume.
#     More info: https://issues.apache.org/jira/browse/NIFI-6484
# We have also allowed docker to create this image as root and not let user 'nifi' have any involvement

ARG IMAGE_NAME=registry.access.redhat.com/ubi8/openjdk-11
ARG IMAGE_TAG=latest
FROM ${IMAGE_NAME}:${IMAGE_TAG}

LABEL maintainer="Apache NiFi <dev@nifi.apache.org>"
LABEL site="https://nifi.apache.org"

ARG UID=1000
ARG GID=1000
ARG NIFI_VERSION=1.15.2
ARG BASE_URL=https://archive.apache.org/dist
ARG MIRROR_BASE_URL=${MIRROR_BASE_URL:-${BASE_URL}}
ARG NIFI_BINARY_PATH=${NIFI_BINARY_PATH:-/nifi/${NIFI_VERSION}/nifi-${NIFI_VERSION}-bin.zip}
ARG NIFI_TOOLKIT_BINARY_PATH=${NIFI_TOOLKIT_BINARY_PATH:-/nifi/${NIFI_VERSION}/nifi-toolkit-${NIFI_VERSION}-bin.zip}

ARG MYSQL_DRIVER=mysql-connector-java-8.0.16
ARG MYSQL_DRIVER_URL=https://dev.mysql.com/get/Downloads/Connector-J/${MYSQL_DRIVER}.zip
ARG POSTGRESQL_DRIVER=postgresql-42.3.1
ARG POSTGRESQL_DRIVER_URL=https://jdbc.postgresql.org/download/${POSTGRESQL_DRIVER}.jar

ENV NIFI_BASE_DIR=/opt/nifi
ENV NIFI_HOME ${NIFI_BASE_DIR}/nifi-current
ENV NIFI_TOOLKIT_HOME ${NIFI_BASE_DIR}/nifi-toolkit-current

ENV NIFI_PID_DIR=${NIFI_HOME}/run
ENV NIFI_LOG_DIR=${NIFI_HOME}/logs

USER root

# OpenSHift UPDATE: git folder sh now has a new ENTRYPOINT script
ADD sh/ ${NIFI_BASE_DIR}/scripts/
RUN chmod -R +x ${NIFI_BASE_DIR}/scripts/*.sh

# Setup NiFi user and create necessary directories
RUN groupadd -g ${GID} nifi || groupmod -n nifi `getent group ${GID} | cut -d: -f1` \
    && useradd --shell /bin/bash -u ${UID} -g ${GID} -m nifi \
    && mkdir -p ${NIFI_BASE_DIR} \
    && chgrp -R 0 ${NIFI_BASE_DIR} \
    && chmod -R g=u ${NIFI_BASE_DIR} \
    && apt-get update \
    && apt-get install -y jq xmlstarlet procps
    
# OpenSHift UPDATE: Do not run as nifi
#USER nifi

# Download, validate, and expand Apache NiFi Toolkit binary.
RUN curl -fSL ${MIRROR_BASE_URL}/${NIFI_TOOLKIT_BINARY_PATH} -o ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.zip \
    && echo "$(curl ${BASE_URL}/${NIFI_TOOLKIT_BINARY_PATH}.sha256) *${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.zip" | sha256sum -c - \
    && unzip ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.zip -d ${NIFI_BASE_DIR} \
    && rm ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.zip \
    && mv ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION} ${NIFI_TOOLKIT_HOME} \
    && ln -s ${NIFI_TOOLKIT_HOME} ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}

# Download, validate, and expand Apache NiFi binary.
RUN curl -fSL ${MIRROR_BASE_URL}/${NIFI_BINARY_PATH} -o ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION}-bin.zip \
    && echo "$(curl ${BASE_URL}/${NIFI_BINARY_PATH}.sha256) *${NIFI_BASE_DIR}/nifi-${NIFI_VERSION}-bin.zip" | sha256sum -c - \
    && unzip ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION}-bin.zip -d ${NIFI_BASE_DIR} \
    && rm ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION}-bin.zip \
    && mv ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION} ${NIFI_HOME} \
    && mkdir -p ${NIFI_HOME}/conf \
    && mkdir -p ${NIFI_HOME}/database_repository \
    && mkdir -p ${NIFI_HOME}/flowfile_repository \
    && mkdir -p ${NIFI_HOME}/content_repository \
    && mkdir -p ${NIFI_HOME}/provenance_repository \
    && mkdir -p ${NIFI_HOME}/state \
    && mkdir -p ${NIFI_LOG_DIR} \
    && ln -s ${NIFI_HOME} ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION} \
    && mkdir -p ${NIFI_HOME}/conf/drivers \
    && curl -fSL ${MYSQL_DRIVER_URL} -o ${NIFI_HOME}/conf/drivers/${MYSQL_DRIVER}.zip \
    && unzip -j ${NIFI_HOME}/conf/drivers/${MYSQL_DRIVER}.zip ${MYSQL_DRIVER}/${MYSQL_DRIVER}.jar -d ${NIFI_HOME}/conf/drivers \
    && curl -fSL ${POSTGRESQL_DRIVER_URL} -o ${NIFI_HOME}/conf/drivers/${POSTGRESQL_DRIVER}.jar
    

VOLUME ${NIFI_LOG_DIR} \
       ${NIFI_HOME}/conf \
       ${NIFI_HOME}/database_repository \
       ${NIFI_HOME}/flowfile_repository \
       ${NIFI_HOME}/content_repository \
       ${NIFI_HOME}/provenance_repository \
       ${NIFI_HOME}/state

# Clear nifi-env.sh in favour of configuring all environment variables in the Dockerfile
RUN echo "#!/bin/sh\n" > $NIFI_HOME/bin/nifi-env.sh

# Web HTTP(s) & Socket Site-to-Site Ports
EXPOSE 8080 8443 10000 8000

WORKDIR ${NIFI_HOME}

# Apply configuration and start NiFi
#
# We need to use the exec form to avoid running our command in a subshell and omitting signals,
# thus being unable to shut down gracefully:
# https://docs.docker.com/engine/reference/builder/#entrypoint
#
# Also we need to use relative path, because the exec form does not invoke a command shell,
# thus normal shell processing does not happen:
# https://docs.docker.com/engine/reference/builder/#exec-form-entrypoint-example
#ENTRYPOINT ["../scripts/start.sh"]

# OpenSHift UPDATE: make new DIR 'nifi-temp' and copy over conf
# This is due to how the OpenShift Persistent Volume works
RUN mkdir nifi-temp && cp -a conf nifi-temp/conf
RUN chmod -R a+rwx nifi-temp/conf

# kick off the custom start script
ENTRYPOINT ["sh", "../scripts/start-openshift-nifi.sh"]
