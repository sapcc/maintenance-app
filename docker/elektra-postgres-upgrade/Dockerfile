FROM keppel.eu-de-1.cloud.sap/ccloud-dockerhub-mirror/library/alpine:3.15

LABEL source_repository="https://github.com/sapcc/maintenance-app"

RUN apk --upgrade --no-cache add git curl postgresql-client bash jq grep openssh xdg-utils nodejs npm

ARG SAP_CERT_URL
ARG SAP_GITHUB_ACCESS_TOKEN
ARG SAP_GITHUB_URL

ENV NAME="pg-upgrade"
ENV PG_VERSION=""
ENV INGRESS_NAME=""
ENV PG_DEPLOYMENT_NAME=""
ENV PG_PVC_NAME=""
ENV PORT=""

# copy maintenance app html files to www=""
# For gitpages we use docs folder to host the app. The name docs is reserved for gitpages.
ADD docs www
RUN npm install -g serve

COPY docker/postgres-upgrade/scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

RUN echo 'alias k="kubectl"' >> ~/.bashrc
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

#CMD serve -l tcp://0.0.0.0:3000 -s www
# RUN serve -l tcp://0.0.0.0:3000 -s www &

ENTRYPOINT [ "/usr/local/bin/upgrade" ]
