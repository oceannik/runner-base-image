# Build a runner base image based on debian 10
FROM debian:11.0-slim AS prebuild

ENV ANSIBLE_CORE_PIP_VERSION=2.11.4
ENV ANSIBLE_PIP_VERSION=4.4.0

### Set up python and pip

RUN apt-get update
RUN apt-get install python3 python3-pip -y

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN pip install ansible-core==${ANSIBLE_CORE_PIP_VERSION}
#RUN pip install ansible==${ANSIBLE_PIP_VERSION}

### Set up dependencies required by the entrypoint.sh script

RUN apt-get install git figlet -y

### Set up Oceannik

ENV OCEANNIK_DIR=/usr/oceannik
WORKDIR ${OCEANNIK_DIR}

RUN mkdir runner-scripts/ user-certs/ user-project/ user-scripts/
COPY build-dependencies/ .
COPY scripts/ runner-scripts/

RUN ansible-galaxy collection install community.general
# RUN ansible-galaxy collection install -r src/deployment-strategies/requirements.yml

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Build a flattened image
FROM scratch

COPY --from=prebuild / /

ENV OCEANNIK_DIR=/usr/oceannik
ENV OCEANNIK_BIN_DIR=${OCEANNIK_DIR}/bin
ENV OCEANNIK_SRC_DIR=${OCEANNIK_DIR}/src
ENV OCEANNIK_RUNNER_SCRIPTS_DIR=${OCEANNIK_DIR}/runner-script
ENV OCEANNIK_USER_CERTS_DIR=${OCEANNIK_DIR}/user-certs
ENV OCEANNIK_USER_PROJECT_DIR=${OCEANNIK_DIR}/user-project
ENV OCEANNIK_USER_SCRIPTS_DIR=${OCEANNIK_DIR}/user-scripts
ENV PATH=${PATH}:${OCEANNIK_BIN_DIR}

WORKDIR ${OCEANNIK_DIR}

CMD ["./entrypoint.sh"]
