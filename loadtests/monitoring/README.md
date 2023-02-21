# MonitoringTests
Docker compose with monitoring configurations tests. Implemented components in the directories:
- `server` - server part, currently set up on `http://central.artipie.com:3000`.
- `client` - client part currently set up on dedicated PC test bench under NAT network.

## Using monitoring
This monitoring solution could be used locally for debugging and profiling of the artipie project. Instructions below were tested on Windows 11/WSL2 + Ubuntu 22.04 environment. Docker and openJDK were installed locally from the ubuntu repositories.

## Run server
Server provides Grafana WEB UI for dashboards, InfluxDB2 is used for permanent metrics storage and Telegraf for metrics collection. 
Some of the docker-compose settings are set in `.env` files.
```
cd monitoring/server
docker-compose up --abort-on-container-exit
```

### Start client
Client runs Artipie instance (monitoring target) and sends its metrics to the server part via Prometheus `remote_write`.
```
cd monitoring/client
./start.sh host.docker.internal admin telegrafadmin1 #Prometheus host, login and passoword
```

## Cleanup

Force stop and remove all volumes and leftovers.

```
cd monitoring
./cleanup.sh ./client
./cleanup.sh ./server
```

## Grafana dashboards

Currently Grafana dashboards are used for monitoring metrics representation. Three dashboards prepared and "provisioned" for the Grafana as `json` files from the directory `monitoring/server/grafana-provisioning/dashboards`:
- `JVM-InfluxDB.json` Essential JVM metrics (GC, heap, threads)
- `Vertx-InfluxDB.json` Vertx framework metrics (requests count, data size)
- `Artipie-metrics-r2-InfluxDB.json` Artipie server metrics (storage, requests)
Dashboards rely on InfluxDB2 and its `Flux` query language.

