FROM apache/nifi:1.11.4

## The following has been changed from https://github.com/apache/nifi.git
#
## NiFi version 1.11.4 will be used
#
#ARG IMAGE_NAME=openjdk
#ARG IMAGE_TAG=11
#FROM ${IMAGE_NAME}:${IMAGE_TAG}

ARG MAINTAINER="C Tassone <tassone.se@gmail.com>"
LABEL maintainer="${MAINTAINER}"
LABEL site="https://github.com/TassoneSE"

#ARG UID=1000
#ARG GID=1000
#ARG NIFI_VERSION=1.11.4
#ARG BASE_URL=https://archive.apache.org/dist
#ARG MIRROR_BASE_URL=${MIRROR_BASE_URL:-${BASE_URL}}
#ARG NIFI_BINARY_PATH=${NIFI_BINARY_PATH:-/nifi/${NIFI_VERSION}/nifi-${NIFI_VERSION}-bin.zip}
#ARG NIFI_TOOLKIT_BINARY_PATH=${NIFI_TOOLKIT_BINARY_PATH:-/nifi/${NIFI_VERSION}/nifi-toolkit-${NIFI_VERSION}-bin.zip}
#
ENV NIFI_BASE_DIR=/opt/nifi
ENV NIFI_HOME ${NIFI_BASE_DIR}/nifi-current
#ENV NIFI_TOOLKIT_HOME ${NIFI_BASE_DIR}/nifi-toolkit-current
#
#ENV NIFI_PID_DIR=${NIFI_HOME}/run
#ENV NIFI_LOG_DIR=${NIFI_HOME}/logs
#
USER root

ADD sh/ ${NIFI_BASE_DIR}/scripts
RUN chmod -R a+x ${NIFI_BASE_DIR}/scripts/*.sh
#
## Setup NiFi user and create necessary directories
#RUN groupadd -g ${GID} nifi || groupmod -n nifi `getent group ${GID} | cut -d: -f1` \
#    && useradd --shell /bin/bash -u ${UID} -g ${GID} -m nifi \
#    && mkdir -p ${NIFI_BASE_DIR} \
#    && chown -R nifi:nifi ${NIFI_BASE_DIR} \
#    && apt-get update \
#    && apt-get install -y jq xmlstarlet procps
#
## Download, validate, and expand Apache NiFi Toolkit binary.
#RUN curl -fSL ${MIRROR_BASE_URL}/${NIFI_TOOLKIT_BINARY_PATH} -o ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.zip \
#    && echo "$(curl ${BASE_URL}/${NIFI_TOOLKIT_BINARY_PATH}.sha256) *${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.zip" | sha256sum -c - \
#    && unzip ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.zip -d ${NIFI_BASE_DIR} \
#    && rm ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}-bin.zip \
#    && mv ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION} ${NIFI_TOOLKIT_HOME} \
#    && ln -s ${NIFI_TOOLKIT_HOME} ${NIFI_BASE_DIR}/nifi-toolkit-${NIFI_VERSION}
#
## Download, validate, and expand Apache NiFi binary.
#RUN curl -fSL ${MIRROR_BASE_URL}/${NIFI_BINARY_PATH} -o ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION}-bin.zip \
#    && echo "$(curl ${BASE_URL}/${NIFI_BINARY_PATH}.sha256) *${NIFI_BASE_DIR}/nifi-${NIFI_VERSION}-bin.zip" | sha256sum -c - \
#    && unzip ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION}-bin.zip -d ${NIFI_BASE_DIR} \
#    && rm ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION}-bin.zip \
#    && mv ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION} ${NIFI_HOME} \
#    && mkdir -p ${NIFI_HOME}/conf \
#    && mkdir -p ${NIFI_HOME}/database_repository \
#    && mkdir -p ${NIFI_HOME}/flowfile_repository \
#    && mkdir -p ${NIFI_HOME}/content_repository \
#    && mkdir -p ${NIFI_HOME}/provenance_repository \
#    && mkdir -p ${NIFI_HOME}/state \
#    && mkdir -p ${NIFI_LOG_DIR} \
#    && ln -s ${NIFI_HOME} ${NIFI_BASE_DIR}/nifi-${NIFI_VERSION}
#
#VOLUME ${NIFI_LOG_DIR} \
#       ${NIFI_HOME}/conf \
#       ${NIFI_HOME}/database_repository \
#       ${NIFI_HOME}/flowfile_repository \
#       ${NIFI_HOME}/content_repository \
#       ${NIFI_HOME}/provenance_repository \
#       ${NIFI_HOME}/state
#
#
## Clear nifi-env.sh in favour of configuring all environment variables in the Dockerfile
#RUN chmod +x ${NIFI_HOME}/bin/nifi-env.sh
#RUN echo "#!/bin/sh\n" > $NIFI_HOME/bin/nifi-env.sh
#
## Web HTTP(s) & Socket Site-to-Site Ports
#EXPOSE 8080 8443 10000 8000
#
#
# Fix the permissions when running in OpenShift
RUN chmod -R +rwx /opt/nifi
RUN find /opt/nifi -type f -iname "*.sh" -exec chmod +x {} \;
RUN chmod +rwx /opt/nifi/nifi-current/conf

WORKDIR ${NIFI_HOME}

RUN mkdir nifi-1.11.4 && cp -a conf nifi-1.11.4/conf
RUN chmod -R +rwx nifi-1.11.4

USER nifi

# Apply configuration and start NiFi
#
# We need to use the exec form to avoid running our command in a subshell and omitting signals,
# thus being unable to shut down gracefully:
# https://docs.docker.com/engine/reference/builder/#entrypoint
#
# Also we need to use relative path, because the exec form does not invoke a command shell,
# thus normal shell processing does not happen:
# https://docs.docker.com/engine/reference/builder/#exec-form-entrypoint-example
#ENTRYPOINT ["sh", "../scripts/start.sh"]



ENTRYPOINT ["sh", "../scripts/start-openshift-nifi.sh"]
