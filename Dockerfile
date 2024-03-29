FROM python:3.7.12-bullseye

ARG SATOSA_DIR=/opt/satosa
ENV SATOSA_DIR ${SATOSA_DIR}
LABEL satosa_dir=${SATOSA_DIR}

ARG SATOSA_USER=satosa
ENV SATOSA_USER ${SATOSA_USER}
LABEL satosa_user=${SATOSA_USER}

ARG SATOSA_GROUP=satosa
ENV SATOSA_GROUP ${SATOSA_GROUP}
LABEL satosa_group=${SATOSA_GROUP}

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        virtualenv \
        xmlsec1

RUN useradd --home-dir ${SATOSA_DIR} --no-create-home --system ${SATOSA_USER} \
    && mkdir -p ${SATOSA_DIR}/plugins \
    && mkdir -p ${SATOSA_DIR}/attributemaps \
    && chown -R ${SATOSA_USER}:${SATOSA_GROUP} ${SATOSA_DIR}

WORKDIR ${SATOSA_DIR}

USER ${SATOSA_USER}

RUN python3 -m venv ${SATOSA_DIR} \
    && ${SATOSA_DIR}/bin/pip install satosa==8.0.0

USER root

RUN apt-get purge -y git \
    && apt-get clean

USER ${SATOSA_USER}

COPY start.sh ${SATOSA_DIR}/
COPY proxy_conf.yaml ${SATOSA_DIR}/
COPY internal_attributes.yaml ${SATOSA_DIR}/
COPY attributemaps ${SATOSA_DIR}/attributemaps
COPY plugins ${SATOSA_DIR}/plugins

ENTRYPOINT ["/bin/bash", "-c", "${SATOSA_DIR}/start.sh"]
