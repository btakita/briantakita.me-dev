#!/bin/sh

_env__validate
RC=$?
if [ $RC -ne 0 ] ; then
	exit $RC
fi
docker compose -p briantakita -f d.briantakita.docker-compose.yml --project-directory . up -d
