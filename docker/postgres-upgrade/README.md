# Setup

## Build Docker image

```bash
./build
```

## Run Docker image

```bash
docker run --rm -it test /bin/bash
```

## Uploading new image

docker login keppel.eu-de-1.cloud.sap
docker push keppel.eu-de-1.cloud.sap/ccloud/elektra-pg-upgrade:latest

# Steps

1. Set the right cluster and namespace if you use u8s. Kubectl should work out of the box.

```u8s
kc qa-de-3
kn elektra
```

2. Set the elektra app in maintance mode. Patch ingress controller with following label:

Set to maintenance:

```bash
kubectl annotate ingress elektra ingress.kubernetes.io/temporal-redirect="https://maintenance.global.cloud.sap"
```

3. Scale down to 0 elektra api (from 4 replicas).
   TODO: store the number of replicas

```
kubectl scale deployment elektra --replicas=0
```

4. Exec into backup container and make one full backup.

```bash
kubectl exec -it deploy/elektra-postgresql -c backup -- /bin/bash -c 'BACKUP_PGSQL_FULL="1 mins" /usr/local/sbin/db-backup.sh'
```

5. Rewrite entrypoint so we are able to remove the db content

```bash
kubectl scale deployment elektra-postgresql --replicas=0
kubectl patch deployment elektra-postgresql --type json  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/bin/bash","-c","exec sleep inf"]}]'
kubectl scale deployment elektra-postgresql --replicas=1
```

6. Remove existing pg folder from the volume

Check content:

```bash
kubectl exec -it deploy/elektra-postgresql -c elektra-postgresql -- /bin/bash -c 'ls -la $PGDATA'
```

Remove content:

WAIT till the new postgresql pod has restarted!

```bash
kubectl exec -it deploy/elektra-postgresql -c elektra-postgresql -- /bin/bash -c 'rm -rf $PGDATA'
```

7. A) Image upgrade

```bash

```

7. B) Revert entrypoint

```bash
kubectl scale deployment elektra-postgresql --replicas=0
kubectl patch deployment elektra-postgresql --type json  -p='[{"op": "remove", "path": "/spec/template/spec/containers/0/command"}]'
kubectl scale deployment elektra-postgresql --replicas=1
```

8. Backup restore automated. The interactive prompt from backup-restore will be unswered allways with the string 5. 5 is the latest backup available.

```bash
kubectl exec -it deploy/elektra-postgresql -c backup -- /bin/bash -c 'yes 5  | backup-restore'
```

9. Scale up to 4 elektra api

```bash
kubectl scale deployment elektra --replicas=4
```

10. Remove maintenance mode:

```bash
kubectl annotate ingress elektra ingress.kubernetes.io/temporal-redirect-
```

# New test deployment

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: pg-upgrade
  name: pg-upgrade
  namespace: elektra
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pg-upgrade
  template:
    metadata:
      labels:
        app: pg-upgrade
    spec:
      containers:
        - image: keppel.eu-de-1.cloud.sap/ccloud/elektra-pg-upgrade:latest
          imagePullPolicy: Always
          name: pg-upgrade
          securityContext:
            runAsUser: 0
          cmd:
            - bash
```

# Todos

- commit .bashrc without hard coded vars
