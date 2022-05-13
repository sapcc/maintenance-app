#!/bin/bash

if [ "$1" = "--help" ]; then
  echo "download files from github.com"
  echo "Usage: download-from-github.com.sh REPONAME_WITH_OWNER TAG FILENAME/LINKNAME"
fi

if [ ! -f "/usr/bin/jq" ]; then
  echo "ERROR: jq (the commandline JSON processor) not found"
  exit 1
fi

REPONAME_WITH_OWNER=$1
if [ -z "$REPONAME_WITH_OWNER" ]; then
  echo "ERROR: no REPONAME_WITH_OWNER found"
  exit 1
fi

TAG=$2
if [ -z "$TAG" ]; then
  echo "ERROR: no TAG found"
  exit 1
fi

FILENAME=$3
if [ -z "$FILENAME" ]; then
  echo "ERROR: no FILENAME found"
  exit 1
fi

# we do not use API because of rate limits :-/
if [ "$TAG" = "latest" ]; then
  # https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8
  ASSET_URL=$(curl -sL "https://github.com/$REPONAME_WITH_OWNER/releases/latest" |
    grep "releases/download.*linux_amd64" |
    cut -d \" -f 2 |
    tr -d \" |
    sed -e 's#.*download/v\(.*\)/aws-iam-authenticator.*#\1#g')

  # this is working to download kube-seal
  if [ -z "$ASSET_URL" ]; then
    ASSET_URL=$(curl -sL "https://github.com/$REPONAME_WITH_OWNER/releases/latest" |
      grep "releases/download.*$FILENAME" | grep -Po '(?<=href=")[^"]*')
  fi

  if [ -z "$ASSET_URL" ]; then
    ASSET_URL=$(curl -sL "https://github.com/$REPONAME_WITH_OWNER/releases/latest" |
      grep "$FILENAME" | grep -Po '(?<=href=")[^"]*')
  fi

  if [ -z "$ASSET_URL" ]; then
    echo "ERROR: cannot find downloadlink for $FILENAME"
    exit 1
  fi

  if [[ "$ASSET_URL" = *https://* ]]; then
    echo "INFO: download from $ASSET_URL"
    wget $ASSET_URL
  else
    echo "INFO: download from https://github.com$ASSET_URL"
    curl -Lo $FILENAME "https://github.com$ASSET_URL"
  fi

else
  echo "INFO: download from https://github.com/$REPONAME_WITH_OWNER/releases/download/$TAG/$FILENAME"
  curl -Lo $FILENAME "https://github.com/$REPONAME_WITH_OWNER/releases/download/$TAG/$FILENAME"
fi