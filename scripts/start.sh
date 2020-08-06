#!/bin/bash

if [ -z "${CODABIX_PROJECT_DIR}" ]; then
    export CODABIX_PROJECT_DIR=/home/codabix/data
fi

# check if codabix has been initialized
if [[ (-z "${CODABIX_INITIALIZED}" ) && (! -f "${CODABIX_PROJECT_DIR}/codabixdb.db") ]];then
    # init codabix
    if [ -z "${CODABIX_ADMIN_PASSWORD}" ]; then
        export CODABIX_ADMIN_PASSWORD=admin
    fi

    echo "admin pw: ${CODABIX_ADMIN_PASSWORD}"

    codabix init --project-directory=${CODABIX_PROJECT_DIR}

    # restore project configuration if environment variable for restore is set
    if [ -n "${CODABIX_RESTORE_FILE}" ]; then
        codabix restore ${CODABIX_RESTORE_FILE} --project-directory=${CODABIX_PROJECT_DIR}
    fi

    codabix settings "{ \"WebServer\": { \"BindingSettings\": { \"UseLocalPort\": true } } }" --project-directory=${CODABIX_PROJECT_DIR}

    if [ -n "${CODABIX_PROJECT_NAME}" ]; then
        codabix settings "{ \"ProjectName\": \"${CODABIX_PROJECT_NAME}\" }" --project-directory=${CODABIX_PROJECT_DIR}
    fi
    codabix set-admin-password ${CODABIX_ADMIN_PASSWORD} --project-directory=${CODABIX_PROJECT_DIR}

    unset ${CODABIX_ADMIN_PASSWORD}
    export CODABIX_INITIALIZED=true
fi

codabix --project-directory=${CODABIX_PROJECT_DIR} $1
