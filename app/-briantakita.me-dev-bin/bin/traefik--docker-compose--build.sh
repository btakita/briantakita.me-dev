#!/bin/sh

_env__validate
RC=$?
if [ $RC -ne 0 ] ; then
	exit $RC
fi
docker compose -p traefik -f d.traefik.docker-compose.yml --project-directory . build
