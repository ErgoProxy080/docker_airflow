#!/bin/bash

: "${POSTGRES_USER:="airflow"}"
: "${POSTGRES_PASS:="airflow"}"
: "${POSTGRES_HOST:="postgres"}"
: "${POSTGRES_PORT:="5432"}"

: "${RABBITMQ_DEFAULT_USER:="airflow"}"
: "${RABBITMQ_DEFAULT_PASS:="airflow"}"
: "${RABBITMQ_DEFAULT_VHOST:="airflow"}"
: "${RABBITMQ_PORT:="5672"}"
: "${RABBITMQ_NODENAME:="rabbit@rabbitmq"}"

: "${AIRFLOW__CORE__FERNET__KEY:="$(python3 /usr/local/bin/fernet.py)"}"
: "${AIRFLOW__CORE__EXECUTOR:="SequentialExecutor"}"


if [ "$AIRFLOW__CORE__EXECUTOR" == "CeleryExecutor" ]; then
    AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASS}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
    AIRFLOW__CELERY__BROKER_URL="amqp://${RABBITMQ_DEFAULT_USER}:${RABBITMQ_DEFAULT_PASS}@rabbitmq:${RABBITMQ_PORT}/${RABBITMQ_DEFAULT_VHOST}"
    AIRFLOW__CELERY__CELERY_RESULT_BACKEND="$AIRFLOW__CORE__SQL_ALCHEMY_CONN"
elif [ "$AIRFLOW__CORE__EXECUTOR" = "SequentialExecutor" && "${MODE:=with_queue}" == "no_queue" ]; then
  AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASS}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
  AIRFLOW__CELERY__CELERY_RESULT_BACKEND="$AIRFLOW__CORE__SQL_ALCHEMY_CONN"
fi

if [[ -z "$AIRFLOW__CORE__LOAD_EXAMPLES" ]]; then
    AIRFLOW__CORE__LOAD_EXAMPLES=False
fi
export \
    AIRFLOW__CORE__FERNET__KEY \
    AIRFLOW__CORE__EXECUTOR \
    AIRFLOW__CORE__SQL_ALCHEMY_CONN \
    AIRFLOW__CELERY__BROKER_URL \
    AIRFLOW__CORE__LOAD_EXAMPLES


case "$1" in
  webserver)
    airflow initdb
    sleep 10
    exec airflow "$@"
    ;;
  scheduler)
    airflow initdb
    sleep 10
    exec airflow "$@"
    ;;
  worker)
    exec airflow "$@"
    ;;
  flower)
    exec airflow "$@"
    ;;
  *)
    exec "$@"
    ;;
esac
