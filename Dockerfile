FROM python:3.6.5-stretch

ARG SRC_DIR=/
ARG AIRFLOW_HOME=/etc/airflow

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -yqq \
                python-pip \
                libffi-dev \
                libxml2-dev \
                libxslt1-dev \
                zlib1g-dev \
                openssh-server

RUN useradd airflow

COPY Pipfile Pipfile.lock ${SRC_DIR}

WORKDIR ${SRC_DIR}

COPY scripts/entrypoint.sh /entrypoint.sh

RUN pip install pipenv

RUN pipenv install --system --deploy

RUN mkdir ${AIRFLOW_HOME}
COPY config/airflow.cfg ${AIRFLOW_HOME}
RUN chown -R airflow: ${AIRFLOW_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]

CMD ["webserver"]
