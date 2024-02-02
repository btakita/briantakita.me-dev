#!/bin/sh

briantakita--docker-compose--build
briantakita-me--docker-compose--restart
docker system prune -f
