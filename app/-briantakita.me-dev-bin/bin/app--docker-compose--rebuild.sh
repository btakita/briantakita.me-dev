#!/bin/sh

docker-compose--build
app--docker-compose--restart
docker system prune -f
