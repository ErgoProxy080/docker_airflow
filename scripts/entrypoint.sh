#!/bin/bash


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
