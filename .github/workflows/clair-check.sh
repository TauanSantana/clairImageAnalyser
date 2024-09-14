#!/bin/bash

set -ex

CONTAINER="clair"
COUNTER=1
MAX=360
LOG1=""
LOG2=""
LOG3=""

while true; do
    # Verifica se a atualização foi concluída
    if docker logs "${CONTAINER}" 2>&1 | grep "update finished" >&/dev/null
    then
        echo "ESTOU AQUI 'update finished'." >&2
        break
    fi

    # Verifica se há algum erro
    if docker logs "${CONTAINER}" 2>&1 | grep "ERROR" >&/dev/null
    then
        echo "ESTOU AQUI 'ERROR'." >&2
        docker logs -n 25 "${CONTAINER}"
        echo "Error during update." >&2
        exit 1
    fi

    # Captura o último log
    CURRENT_LOG=$(docker logs -n 1 "${CONTAINER}")

    # Shift logs: move o log mais recente para frente e armazena o novo log
    LOG3="$LOG2"
    LOG2="$LOG1"
    LOG1="$CURRENT_LOG"


    # Verifica se as últimas 3 iterações tiveram a mesma mensagem de log
    if [ "$LOG1" == "$LOG2" ] && [ "$LOG2" == "$LOG3" ] && [ -n "$LOG1" ]; then
        echo "As últimas 3 iterações têm a mesma mensagem de log. Interrompendo o loop." >&2
        break
    fi

    docker logs "${CONTAINER}"

    # Aguarda 10 segundos antes da próxima iteração
    sleep 10
    ((COUNTER++))

    # Verifica se o contador atingiu o limite
    if [ "${COUNTER}" -eq "${MAX}" ]; then
        echo "Took too long."
        exit 1
    fi
done

echo "Processo finalizado com sucesso."
