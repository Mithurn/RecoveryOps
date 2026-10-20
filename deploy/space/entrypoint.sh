#!/usr/bin/env bash
set -euo pipefail
PGBIN=$(ls -d /usr/lib/postgresql/*/bin)
PGDATA=$HOME/pgdata
PSQL="$PGBIN/psql -h 127.0.0.1 -U recovery -v ON_ERROR_STOP=1"

$PGBIN/initdb -D "$PGDATA" -U recovery --auth=trust >/dev/null
$PGBIN/pg_ctl -D "$PGDATA" -o "-c listen_addresses=127.0.0.1 -c unix_socket_directories=/tmp" -l "$HOME/pg.log" -w start >/dev/null
$PSQL -d postgres -c "CREATE DATABASE recovery" >/dev/null
$PSQL -d recovery -q -f db/schema.sql >/dev/null

redis-server --daemonize yes --save "" --appendonly no >/dev/null
npm run -s seed:room
exec npx tsx src/main.ts
