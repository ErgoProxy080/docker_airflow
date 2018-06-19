FROM python:3.6.5-alpine

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -yqq \
                python-pip \
                python3.6-minimal \
                python3.6-dev \
                libmysqlclient-dev \
                libffi-dev \
                libxml2-dev \
                libxslt1-dev \
                zlib1g-dev \
                ssh

RUN useradd airflow

COPY Pipfile Pipfile.lock ${SRC_DIR}/

WORKDIR ${SRC_DIR}

COPY scripts/entrypoint.sh /entrypoint.sh

RUN pip install pipenv --system --deploy

RUN pipenv install --system --deploy

COPY config/airflow.cfg ${AIRFLOW_HOME}
RUN chown -R airflow: ${AIRFLOW_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]

CMD ["webserver"]
