FROM python:3.6.5-stretch

ARG SRC_DIR=/
ARG AIRFLOW_HOME=/usr/local/airflow

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -yqq \
                python-pip \
                libffi-dev \
                libxml2-dev \
                libxslt1-dev \
                zlib1g-dev \
                openssh-server

RUN useradd -d ${AIRFLOW_HOME} airflow

COPY Pipfile Pipfile.lock ${SRC_DIR}

WORKDIR ${SRC_DIR}

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/fernet.py /usr/local/bin/fernet.py

RUN pip install pipenv

RUN pipenv install --system --deploy && \
    rm -rf /root/.cache/.pip

RUN mkdir ${AIRFLOW_HOME}
COPY config/airflow.cfg ${AIRFLOW_HOME}
RUN chown -R airflow: ${AIRFLOW_HOME}

RUN apt-get clean

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["webserver"]
