# MonitoringTests
Docker compose with monitoring configurations tests. Server part currently runs on `http://central.artipie.com:3000`.
Client part currently runs on dedicated PC under NAT network.

## Run server
Server provides Grafana WEB UI, InfluxDB2 is used for permanent storage and Telegraf for metrics collection.
```
cd server
docker-compose up --abort-on-container-exit
```

### Start client
Client runs Artipie instance (test target) and sends its metrics to the server part via Prometheus remote_write.
```
cd client
./start.sh host.docker.internal admin telegrafadmin1
```

## Cleanup

Force stop and remove all volumes and leftovers.

```
cd monitoring
./cleanup.sh ./client
./cleanup.sh ./server
```
