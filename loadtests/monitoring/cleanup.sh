#!/bin/bash -e
if [ $# -ne 1 ]; then 
    echo "Usage: $0 path" && exit 1
fi
cd "$1"

docker-compose down || :
docker-compose rm -fsv
docker volume prune -f
docker system prune -f

