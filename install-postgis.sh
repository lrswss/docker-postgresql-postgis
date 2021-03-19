#!/bin/sh
set -e
for DB in template1 postgres; do
	echo "Loading PostGIS extensions into $DB..."
	psql -v ON_ERROR_STOP=1 --username $POSTGRES_USER --no-password --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS postgis;
EOSQL
done
