#!/usr/bin/env bash
set -x

MSG_PREFIX="[Oceannik Entrypoint]"

figlet Oceannik

echo "${MSG_PREFIX} Display package versions"
ansible --version
ocean version

echo "${MSG_PREFIX} Clone the user's project repository"
git clone https://github.com/oceannik/examples ${OCEANNIK_USER_PROJECT_DIR}

echo "${MSG_PREFIX} Fetch secrets"

PULLED_SECRETS_DIR=/tmp/pulled-secrets

mkdir -p ${PULLED_SECRETS_DIR}/ ~/.oceannik/certs/ ~/.oceannik/certs/oceannik_ca/ ~/.ssh/oceannik/
cp -r ${OCEANNIK_USER_CERTS_DIR}/* ~/.oceannik/certs/
mv ~/.oceannik/certs/oceannik_ca.crt ~/.oceannik/certs/oceannik_ca/oceannik_ca.crt
mv ~/.oceannik/certs/oceannik_runner.crt ~/.oceannik/certs/oceannik_client.crt
mv ~/.oceannik/certs/oceannik_runner.key ~/.oceannik/certs/oceannik_client.key

ocean secrets pull --host ${HOST:=localhost} --port ${PORT:=5000} --output-dir ${PULLED_SECRETS_DIR}

cp -r ${PULLED_SECRETS_DIR}/INFRA_SSH_PRIVATE_KEY* ~/.ssh/oceannik/
chmod 600 ~/.ssh/oceannik/INFRA_SSH_PRIVATE_KEY*

echo "${MSG_PREFIX} Copy inventory"

cp ${PULLED_SECRETS_DIR}/HOSTS_FILE ${OCEANNIK_SRC_DIR}/deployment-strategies/inventory
cat ${OCEANNIK_SRC_DIR}/deployment-strategies/inventory

echo "${MSG_PREFIX} Set environment variables"

OCEANNIK_SERVICE_CONFIG_PATH=${OCEANNIK_USER_PROJECT_DIR}/${OCEANNIK_SERVICE_CONFIG_PATH}

echo "${MSG_PREFIX} Configure and start the deployment"

python runner-scripts/pre_deployment.py

cd ${OCEANNIK_SRC_DIR}/deployment-strategies

ansible-playbook start-deployment.yml

cd ${OCEANNIK_DIR}

python runner-scripts/post_deployment.py
