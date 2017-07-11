#!/bin/sh
start_time=$(date +%s)

command=scalingo
version=$($command -v)
if [ $? -ne 0 ]; then
  echo "You must install scalingo CLI: http://cli.scalingo.com"
  exit 1
fi

env=$1
if [ -z "$env" ]; then
  echo "Usage: $0 <env>"
  echo "Env must be: 'production', 'demo' or 'staging'."
  exit 2
fi

secrets=$($command -a anah-$env env | grep "POSTGRESQL_URL=" | sed "s/^.*=//")
pgpassword=$(echo $secrets | sed "s/^.*:\([0-9a-zA-Z]*\)@.*$/\1/")
pguser=$(echo $secrets | sed "s/^.*\/\/\([^:]*\):.*$/\1/")

DATE=$(date +%Y-%m-%d_%H-%M-%S)

echo "Downloading the dump…"
PGPASSWORD=$pgpassword pg_dump --clean --format c --host 127.0.0.1 --port 10000 --username $pguser --no-owner --no-privileges --exclude-schema 'information_schema' --exclude-schema '^pg_*' --dbname $pguser --file anah_${env}_${DATE}.pgsql

echo "Done! (in $(expr $(date +%s) - $start_time) seconds)"

