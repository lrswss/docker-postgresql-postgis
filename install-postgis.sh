#!/bin/sh
set -e

if [ -z "$POSTGRES_USER" ]; then
	echo "ERROR: POSTGRES_USER not set!"
	exit 1
fi

if ! psql -tqc '\dx' | cut -d '|' -f 1 | grep -qw postgis; then
	for DB in template1 postgres; do
		echo "create extension if not exists postgis;" | \
			psql -v ON_ERROR_STOP=1 --username $POSTGRES_USER \
			--no-password --dbname="$DB"
	done
fi
