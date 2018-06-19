#!/bin/bash

: ${POSTGRES_USER:="airflow"}
: ${POSTGRES_PASS:="airflow"}
: ${POSTGRES_HOST:="postgres"}
: ${POSTGRES_PORT:="5432"}

: ${RABBITMQ_DEFAULT_USER:="airflow"}
: ${RABBITMQ_DEFAULT_PASS:="airflow"}
: ${RABBITMQ_DEFAULT_VHOST:="airflow"}
: ${RABBITMQ_PORT:="5672"}

: "${AIRFLOW__CORE__FERNET__KEY:=${FERNET_KEY:=$(python3 fernet.key.py)}}"
: "${AIRFLOW__CORE__EXECUTOR:=${AIRFLOW_EXECUTOR:-Local}Executor}"


if ["$AIRFLOW__CORE__EXECUTOR" == "Celery" ]; then
    AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://${POSTGRES_USER}:${POSTGRES_PASS}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"
    AIRFLOW__CELERY__BROKER_URL="amqp://${RABBITMQ_DEFAULT_USER}:${RABBITMQ_DEFAULT_PASS}:${RABBITMQ_PORT}/${RABBITMQ_DEFAULT_VHOST}"
fi

export \
    $AIRFLOW__CORE__FERNET__KEY \
    $AIRFLOW__CORE__EXECUTOR \
    $AIRFLOW__CORE__SQL_ALCHEMY_CONN \
    $AIRFLOW__CELERY__BROKER_URL




case "$1" in
  webserver)
    exec airflow "$?"
    ;;
  scheduler)
    initdb
    sleep 10
    exec airflow "$?"
    ;;
  worker)
    exec airflow "$?"
    ;;
  flower)
    exec airflow "$?"
    ;;
  *)
    exec "$?"
    ;;
esac
