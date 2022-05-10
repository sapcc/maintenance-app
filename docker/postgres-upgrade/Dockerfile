ARG DOCKERHUB
FROM $DOCKERHUB/alpine:3.15

LABEL source_repository="https://github.com/sapcc/maintenance-app"

RUN apk --upgrade --no-cache add git curl postgresql-client bash jq grep openssh xdg-utils

ARG SAP_CERT_URL
ARG SAP_GITHUB_ACCESS_TOKEN
ARG SAP_GITHUB_URL

COPY download-from-github.com download-from-github.sap install_kubectl /usr/local/bin/

RUN chmod 0755 /usr/local/bin/download-from-github.com /usr/local/bin/download-from-github.sap /usr/local/bin/install_kubectl

# SAP certs (e.g. for sap github)
RUN if $INSTALL_CC_TOOLS; then curl -fL $SAP_CERT_URL | tr -d '\r' > /usr/local/share/ca-certificates/SAP_Global_Root_CA.crt \
    && update-ca-certificates; fi

# install kubectl logon
RUN download-from-github.sap $SAP_GITHUB_URL $SAP_GITHUB_ACCESS_TOKEN cc/kubectl-logon latest kubectl-logon_linux_amd64 \
      && chmod 0755 kubectl-logon_linux_amd64 \
      && mv kubectl-logon_linux_amd64 /usr/local/bin/kubectl-logon

# install kubectl sync
RUN download-from-github.sap $SAP_GITHUB_URL $SAP_GITHUB_ACCESS_TOKEN monsoon/kubectl-sync latest kubectl-sync_linux_amd64 \
      && chmod 0755 kubectl-sync_linux_amd64 \
      && mv kubectl-sync_linux_amd64 /usr/local/bin/kubectl-sync

# install u8s
RUN download-from-github.sap $SAP_GITHUB_URL $SAP_GITHUB_ACCESS_TOKEN cc/u8s latest u8s_linux_amd64 \
      && chmod 0755 u8s_linux_amd64 \
      && mv u8s_linux_amd64 /usr/local/bin/u8s

# kubectl v1.21.5
ARG KUBECTL_VERSIONS="v1.21.5:default"
RUN install_kubectl ${KUBECTL_VERSIONS}

# custom bashrc for u8s
# COPY .bashrc /root/.bashrc

# RUN kubectl annotate ingress elektra ingress.kubernetes.io/temporal-redirect="https://maintenance.global.cloud.sap" && \ 
#       kubectl scale deployment elektra --replicas=0 && \
#       kubectl exec -it deploy/elektra-postgresql -c backup -- /bin/bash -c 'BACKUP_PGSQL_FULL="1 mins" /usr/local/sbin/db-backup.sh'

# RUN echo -e '#!/bin/bash\n\n\
# echo "Set the elektra app in maintance mode..."\n\
# kubectl annotate ingress elektra ingress.kubernetes.io/temporal-redirect="https://maintenance.global.cloud.sap"\n\
# echo "Scale down to 0 elektra api..."\n\
# kubectl scale deployment elektra --replicas=0\n\
# echo "Exec into backup container and make one full backup..."\n\
# kubectl exec -it deploy/elektra-postgresql -c backup -- /bin/bash -c '"'"'BACKUP_PGSQL_FULL="1 mins" /usr/local/sbin/db-backup.sh'"'"'\n\
# /bin/sh -c $@' >> /usr/local/bin/upgrade_db && chmod +x /usr/local/bin/upgrade_db

COPY upgrade.sh /usr/local/bin/upgrade
RUN chmod +x /usr/local/bin/upgrade

ENTRYPOINT [ "/usr/local/bin/upgrade" ]  