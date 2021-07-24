#!/usr/bin/env bash
# based on https://github.com/docker-library/postgres/blob/master/11/docker-entrypoint.sh

PATH=$PATH:/usr/lib/postgresql/$POSTGRES_MAJOR_VERSION/bin
set -Eeo pipefail


# usage: docker_process_init_files [file [file [...]]]
#    ie: docker_process_init_files /always-initdb.d/*
# process initializer files once, based on file extensions and permissions
docker_process_init_files() {
	echo "Processing init scripts..."
	local f
	for f; do
		case "$f" in
			*.sh)
				if [ -x "$f" ]; then
					echo "$0: running $f"
					"$f"
				else
					echo "$0: sourcing $f"
					. "$f"
				fi
				;;
			*.sql)    echo "$0: running $f"; docker_process_sql -f "$f"; echo ;;
			*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | docker_process_sql; echo ;;
			*.sql.xz) echo "$0: running $f"; xzcat "$f" | docker_process_sql; echo ;;
			*)        echo "$0: ignoring $f" ;;
		esac
	done
}


# Execute sql script, passed via stdin (or -f flag of pqsl)
# usage: docker_process_sql [psql-cli-args]
#    ie: docker_process_sql --dbname=mydb <<<'INSERT ...'
#    ie: docker_process_sql -f my-file.sql
#    ie: docker_process_sql <my-file.sql
docker_process_sql() {
	local query_runner=( psql -v ON_ERROR_STOP=1 --username 'postgres' --no-password )
	PGHOST= PGHOSTADDR= "${query_runner[@]}" "$@"
}


# Path to configuration files and postgresql username on Debian
export PGDATA=/etc/postgresql/$POSTGRES_MAJOR_VERSION/main
export POSTGRES_USER=postgres
	
if [ "$1" = "postgres" ]; then
	if [ "$(id -u)" = "0" ]; then
		# restart script as user postgres
		exec setpriv --reuid=postgres --regid=postgres --init-groups "$BASH_SOURCE" "$@"
	fi

	# only called once when container is initially setup
	# make postgresql remotely accessible, add postgis extension, call init scripts
	if [ -z "$(cat $PGDATA/pg_hba.conf | grep '0.0.0.0/0')" ]; then
		echo "listen_addresses = '*'" >> $PGDATA/postgresql.conf
		echo "host all all 0.0.0.0/0 md5" >> $PGDATA/pg_hba.conf
		pg_ctlcluster 11 main start
		/var/lib/postgresql/install-postgis.sh
		docker_process_init_files /docker-entrypoint-initdb.d/*
		pg_ctlcluster 11 main stop
		echo "Initial postgresql/postgis setup completed!"
	fi

	echo "Starting PostgresSQL version $POSTGRES_MAJOR_VERSION..."
	exec postgres -D $PGDATA
else
	exec "$@"
fi
