#!/bin/sh

docker-compose -p traefik -f d.traefik.docker-compose.yml --project-directory . up -d
