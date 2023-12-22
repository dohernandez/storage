#!/usr/bin/env bash

[ -z "$POSTGRES_TEST_HOST" ] && POSTGRES_TEST_HOST="localhost"
[ -z "$POSTGRES_TEST_PORT" ] && POSTGRES_TEST_PORT="5432"
[ -z "$POSTGRES_TEST_USER" ] && POSTGRES_TEST_USER=$(whoami)
[ -z "$POSTGRES_TEST_PASSWORD" ] && POSTGRES_TEST_PASSWORD="tests"
[ -z "$POSTGRES_TEST_DATABASE" ] && POSTGRES_TEST_DATABASE="postgres"
[ -z "$DOCKER_POSTGRES_TAG" ] && DOCKER_POSTGRES_TAG="latest"

if ! pg_isready --host="$POSTGRES_TEST_HOST" --port="$POSTGRES_TEST_PORT"  --dbname="$POSTGRES_TEST_DATABASE" > /dev/null; then \
  echo "Postgres service is not running."
  echo ""
  echo "You can spin up a postgres instance by running the following command using docker:"
  echo ""
  echo docker run -d \
        --name toolkit-postgres \
        -e POSTGRES_PASSWORD=$POSTGRES_TEST_PASSWORD \
        -e POSTGRES_HOST_AUTH_METHOD=trust \
        -e POSTGRES_USER=$POSTGRES_TEST_USER \
        -e POSTGRES_DB=$POSTGRES_TEST_DATABASE \
        -p $POSTGRES_TEST_PORT:5432 \
        postgres:$DOCKER_POSTGRES_TAG
  echo ""
  echo "or this other commands using brew:"
  echo ""
  echo "brew install posgresql && brew services start postgresql"
  echo ""

  exit 1
fi