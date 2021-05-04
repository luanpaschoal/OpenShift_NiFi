ARG IMAGE_NAME=apache/nifi
ARG IMAGE_TAG=1.11.4
FROM ${IMAGE_NAME}:${IMAGE_TAG}

ARG MAINTAINER="C Tassone <tassone.se@gmail.com>"
LABEL maintainer="${MAINTAINER}"
LABEL site="https://github.com/TassoneSE"

# fix the config issue for Openshift    

#RUN chmod -R ugo+x ${NIFI_HOME}/conf
#RUN chmod -R o+rwx ${NIFI_HOME}/bin/*.sh

RUN mkdir nifi-temp && cp -a conf nifi-temp/conf

COPY --chown=nifi:nifi start-openshift-nifi.sh ../scripts

RUN chmod a+x ../scripts/start-openshift-nifi.sh

RUN chmod -R a+rwx ${NIFI_HOME}

ENTRYPOINT ["sh", "../scripts/start-openshift-nifi.sh"]
