#!/bin/bash

set -ex

CONTAINER="clair"
COUNTER=1
MAX=360
ITERATION_COUNT=0
LOG_COUNT=2

while true; do
    # Verifica se a atualização foi concluída
    if docker logs "${CONTAINER}" 2>&1 | grep "update finished" >&/dev/null
    then
        echo "update finished." >&2
        break
    fi

    # Verifica se há algum erro
    if docker logs "${CONTAINER}" 2>&1 | grep "ERROR" >&/dev/null
    then
        docker logs -n 25 "${CONTAINER}"
        echo "Error during update." >&2
        exit 1
    fi

    # Obtém o último log e verifica se contém apenas 'updater service started'
    LAST_LOG=$(docker logs -n 1 "${CONTAINER}")
    if echo "$LAST_LOG" | grep -q "updater service started"; then
        ((ITERATION_COUNT++))
    else
        ITERATION_COUNT=0  # Reseta o contador se encontrar um log diferente
    fi

    # Se os últimos 3 logs forem 'updater service started', interrompe o loop
    if [ "$ITERATION_COUNT" -ge "$LOG_COUNT" ]; then
        echo "Os últimos 3 logs contêm apenas 'updater service started'. Interrompendo o loop." >&2
        break
    fi

    # Exibe o último log
    echo "$LAST_LOG"
    sleep 10
    ((COUNTER++))

    # Verifica se o contador atingiu o limite
    if [ "${COUNTER}" -eq "${MAX}" ]; then
        echo "Took too long."
        exit 1
    fi
done

echo "Processo finalizado com sucesso."
