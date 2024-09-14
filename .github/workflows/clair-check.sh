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

        # Verifica os últimos 3 logs
    LAST_THREE_LOGS=$(docker logs -n 2 "${CONTAINER}")
    if echo "$LAST_THREE_LOGS" | grep -q "updater service started"; then
        COUNT_MATCHES=$(echo "$LAST_THREE_LOGS" | grep -c "updater service started")
        if [ "$COUNT_MATCHES" -eq 3 ]; then
            echo "Os últimos 3 logs são 'updater service started'. Não há atualização." >&2
            break
        fi
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