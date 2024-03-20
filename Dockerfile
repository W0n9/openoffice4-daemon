FROM bitnami/java:1.8.402-7-debian-12-r7

## Build Env vars
ARG OO_VERSION=4.1.15
ARG OO_TGZ_URL="https://jaist.dl.sourceforge.net/project/openofficeorg.mirror/${OO_VERSION}/binaries/zh-CN/Apache_OpenOffice_${OO_VERSION}_Linux_x86-64_install-deb_zh-CN.tar.gz"
# ARG OO_LANGPACK="https://jaist.dl.sourceforge.net/project/openofficeorg.mirror/${OO_VERSION}/binaries/zh-CN/Apache_OpenOffice_${OO_VERSION}_Linux_x86-64_install-deb_zh-CN.tar.gz"

ENV SOFFICE_DAEMON_PORT=8100
ENV APP_ROOT=/opt/app-root
ENV PATH=${APP_ROOT}/bin:${PATH} HOME=${APP_ROOT}

### Atomic/OpenShift Labels - https://github.com/projectatomic/ContainerApplicationGenericLabels
LABEL name="w0n9/openoffice4-daemon" \
      version="4.1.15" \
      release="1" \
      summary="Openoffice 4 headless mode (soffice)" \
      description="Start the Openoffice headless daemon listening on ${SOFFICE_DAEMON_PORT}" \
      url="https://github.com/W0n9/openoffice4-daemon" \
      run='docker run -tdi --name ${NAME} -u 123456 ${IMAGE}' \
      io.k8s.description="Start the Openoffice headless daemon listening on ${SOFFICE_DAEMON_PORT}" \
      io.k8s.display-name="Openoffice headless daemon" \
      io.openshift.expose-services="soffice" \
      io.openshift.tags="openoffice,headless,daemon,starter-arbitrary-uid,starter,arbitrary,uid"

RUN install_packages wget libxext6 libxt6 libxrender1 && \
    wget -P /tmp ${OO_TGZ_URL} && \
    tar -xzvf /tmp/Apache_OpenOffice_${OO_VERSION}_Linux_x86-64_install-deb_zh-CN.tar.gz -C /tmp && \
    install_packages /tmp/*/DEBS/*.deb && \
    rm -rf /tmp/*

COPY bin/ ${APP_ROOT}/bin/

RUN chmod -R u+x ${APP_ROOT}/bin && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd

# ### Containers should NOT run as root as a good practice
USER 1001
WORKDIR ${APP_ROOT}

EXPOSE ${SOFFICE_DAEMON_PORT}

### user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
ENTRYPOINT [ "uid_entrypoint" ]
CMD run
