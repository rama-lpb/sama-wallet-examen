#!/bin/sh
set -eu
: "${DB_HOST:?DB_HOST manquant}"
: "${DB_PORT:?DB_PORT manquant}"
: "${DB_NAME:?DB_NAME manquant}"
: "${DB_USER:?DB_USER manquant}"
: "${DB_PASSWORD:?DB_PASSWORD manquant}"
export SPRING_DATASOURCE_URL="jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}"
export SPRING_DATASOURCE_USERNAME="$DB_USER"
export SPRING_DATASOURCE_PASSWORD="$DB_PASSWORD"
export SERVER_PORT="${PORT:-10000}"
exec java -XX:MaxRAMPercentage=65 -XX:ActiveProcessorCount=2 -jar /app/app.jar
