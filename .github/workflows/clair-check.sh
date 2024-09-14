#!/bin/bash

set -ex

CONTAINER="clair"
COUNTER=1
MAX=360

while true; do
    if docker logs "${CONTAINER}" 2>&1 | grep "update finished" >&/dev/null
    then
        echo "ESTOU AQUI 'update finished'." >&2
        break
    fi

    if docker logs "${CONTAINER}" 2>&1 | grep "ERROR" >&/dev/null
    then
        echo "ESTOU AQUI 'ERROR'." >&2
        docker logs -n 25 "${CONTAINER}"
        echo "Error during update." >&2
        exit 1
    fi

    docker logs -n 1 "${CONTAINER}"
    sleep 10
    ((COUNTER++))

    if [ "${COUNTER}" -eq "${MAX}" ]; then
        echo "Took to long"
        exit 1
    fi
done
echo ""