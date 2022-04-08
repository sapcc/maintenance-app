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

# custom bashrc
COPY .bashrc /root/.bashrc