# Setup

## Build Docker image

```bash
./build
```

## Run Docker image

```bash
docker run -it test /bin/bash
```

# Steps

1. Set the right cluster and namespace

```
kc qa-de-3
kn elektra
```

2. Set the elektra app in maintance mode. Edit ingress controller and add following label:

```
ingress.kubernetes.io/temporal-redirect: https://maintenance.global.cloud.sap
```

1. Exec into backup sidecar on new pod and make one full backup:

```bash
BACKUP_PGSQL_FULL="1 mins" /usr/local/sbin/db-backup.sh
```

# Todos

- commit .bashrc without hard coded vars
