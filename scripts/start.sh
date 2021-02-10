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

    # create the project
    codabix create --project-directory=${CODABIX_PROJECT_DIR}

    # apply basic settings
    codabix settings "{ \"WebServer\": { \"BindingSettings\": { \"UseLocalPort\": true } } }" --project-directory=${CODABIX_PROJECT_DIR}

    if [ -n "${CODABIX_PROJECT_SETTINGS}" ]; then
        codabix settings "${CODABIX_PROJECT_SETTINGS}" --project-directory=${CODABIX_PROJECT_DIR}
    fi

    # wait until database is available
    # and initialize the database
    i="0"
    connectionStatus="1"
    echo "Checking connection to back end database."
    while [ $i -lt 10 ]
    do
        codabix init --upgrade --project-directory=${CODABIX_PROJECT_DIR}
        connectionStatus=$?
        if [ $connectionStatus -ne 0 ];then
            echo "Back end database not available. Retrying in 2 seconds."
            sleep 2
            i=$[$i+1]
        else
            echo "Back end database available."
            echo "Initialized back end database."
            break
        fi
    done
    if [ $connectionStatus -ne 0 ];then
        echo "Could not connect to back end database. Please check your project settings:"
        codabix settings --project-directory=${CODABIX_PROJECT_DIR}
        echo "Now exiting..."
        exit 1;
    fi


    # restore project configuration if environment variable for restore is set (this will keep the current project settings, except for the project name)
    if [ -n "${CODABIX_RESTORE_FILE}" ]; then
        codabix restore ${CODABIX_RESTORE_FILE} -y --project-directory=${CODABIX_PROJECT_DIR}
    fi

    # set the project name after restoring the backup, as the restore command changes the project name to the one from the backup
    if [ -n "${CODABIX_PROJECT_NAME}" ]; then
        codabix settings "{ \"ProjectName\": \"${CODABIX_PROJECT_NAME}\" }" --project-directory=${CODABIX_PROJECT_DIR}
    fi

    codabix set-admin-password ${CODABIX_ADMIN_PASSWORD} --project-directory=${CODABIX_PROJECT_DIR}

    unset ${CODABIX_ADMIN_PASSWORD}
    export CODABIX_INITIALIZED=true
fi

codabix init --upgrade --project-directory=${CODABIX_PROJECT_DIR}

codabix --project-directory=${CODABIX_PROJECT_DIR} $1
