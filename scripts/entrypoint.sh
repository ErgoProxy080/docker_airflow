#!/bin/bash

: ${AIRFLOW__CORE__FERNET__KEY}:=${FERNET_KEY}:=$(python3 fernet.key.py)

exports() {
  export \
    $AIRFLOW__CORE__FERNET__KEY  
}



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
