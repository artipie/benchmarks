# MonitoringTests
Docker compose with monitoring configurations tests

## Run server
```
cd server
docker-compose up --abort-on-container-exit
```

### Start client
```
cd client
./start.sh host.docker.internal admin telegrafadmin1
```

