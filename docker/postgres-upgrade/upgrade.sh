#!/bin/bash

echo "Set the elektra app in maintance mode..."
kubectl annotate ingress elektra ingress.kubernetes.io/temporal-redirect="https://maintenance.global.cloud.sap"

echo "Scale down to 0 elektra api..."
kubectl scale deployment elektra --replicas=0

echo "Exec into backup container and make one full backup..."
kubectl exec -it deploy/elektra-postgresql -c backup -- /bin/bash -c 'BACKUP_PGSQL_FULL="1 mins" /usr/local/sbin/db-backup.sh'

echo "Rewrite entrypoint so we are able to remove the db content"
kubectl scale deployment elektra-postgresql --replicas=0
kubectl patch deployment elektra-postgresql --type json  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/bin/bash","-c","exec sleep inf"]}]'
kubectl scale deployment elektra-postgresql --replicas=1


echo "Remove existing pg folder from the volume"
# WAIT till the new postgresql pod has restarted!

kubectl exec -it deploy/elektra-postgresql -c elektra-postgresql -- /bin/bash -c 'rm -rf $PGDATA'

# Image upgrade

echo "Revert entrypoint"
kubectl scale deployment elektra-postgresql --replicas=0
kubectl patch deployment elektra-postgresql --type json  -p='[{"op": "remove", "path": "/spec/template/spec/containers/0/command"}]'
kubectl scale deployment elektra-postgresql --replicas=1

echo "Backup restore automated. The interactive prompt from backup-restore will be unswered allways with the string 5. 5 is the latest backup available."
kubectl exec -it deploy/elektra-postgresql -c backup -- /bin/bash -c 'yes 5  | backup-restore'

echo "Scale up to 4 elektra api"
kubectl scale deployment elektra --replicas=4

echo "Remove maintenance mode"
kubectl annotate ingress elektra ingress.kubernetes.io/temporal-redirect-


/bin/sh -c $@