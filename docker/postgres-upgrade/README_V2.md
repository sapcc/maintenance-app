# Upgrade PG DB

1. redirect consumer to maintenance

```bash
kubectl annotate ingress elektra ingress.kubernetes.io/temporal-redirect="https://maintenance.global.cloud.sap"
```

2. exec pg container and execute backup

```bash
kubectl exec -it deploy/elektra-postgresql -c backup -- /bin/bash -c 'BACKUP_PGSQL_FULL="1 mins" /usr/local/sbin/db-backup.sh'
```

3. detirmine mount point

```bash
PGDATA=$(kubectl exec -it deploy/elektra-postgresql -c elektra-postgresql -- /bin/bash -c 'echo $PGDATA')
VOLUME_MOUNTS=$(kubectl -n elektra get deploy/elektra-postgresql -o jsonpath='{.spec.template.spec.containers[?(@.name=="elektra-postgresql")].volumeMounts}' )
VOLUMES=$(kubectl -n elektra get pods -o jsonpath='{.items[*].spec.containers[?(@.name=="elektra-postgresql")].volumeMounts}')

```

4. scale down pg pod

```bash
kubectl scale deployment elektra-postgresql --replicas=0
kubectl wait --for delete pod --selector=app=elektra-postgresql --timeout=300s
```

5. run pod with mount point

```bash
kubectl -n elektra run terminator --image busybox --rm -ti --restart=Never --overrides='
{
    "spec": {
        "containers": [
            {
                "stdin": true,
                "tty": true,
                "args": [ "sh", "-c", "rm -rf /postgresql/data" ],
                "name": "db-terminator",
                "image": "busybox",
                "volumeMounts": [
                    {
                      "mountPath": "/postgresql",
                      "name": "data"
                    }
                ]
            }
        ],
        "volumes": [
          {
            "name": "data",
            "persistentVolumeClaim": {
                "claimName": "elektra-postgresql"
            }
          }
        ]
    }
}
'
```

6. scale up pg pod

7. restore backup

8. revert redirect to maintenance
