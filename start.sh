#!/bin/bash

set -e

if [ "x${SQL_SERVER}" -ne '' ] && [ "x${SQL_SERVER_PORT}" -ne '' ]; then
	until timeout 1 bash -c "cat < /dev/null > /dev/tcp/${SQL_SERVER}/${SQL_SERVER_PORT}"; do
		echo "Wait for SQL server to start at ${SQL_SERVER}:${SQL_SERVER_PORT} ..."
		sleep 1
	done
fi

/opt/jboss/wildfly/bin/standalone.sh "$@"