# Build

```bash
cd maintenance-app/docker/elektra-postgresql-upgrade
cp .env.sample .env
./build
docker push keppel.eu-de-1.cloud.sap/ccloud/elektra-pg-upgrade
```

# Usage

1. kubectl config use-context REGION

2. kubectl logon

3. a) kubectl -n elektra apply -f pg-upgrade-deploy.yaml
4. b) kubectl -n elektra get pods --watch

5. kubectl -n elektra delete rolebinding pg-upgrade

6. adjust the helm chart

# Info

see scripts/upgrade
