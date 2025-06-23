#!/bin/bash

set -e

attempt=0
retry_wait_time=30
MAX_ATTEMPTS=10

while [ $attempt -lt $MAX_ATTEMPTS ]; do
    storageclass=$(kubectl get storageclass | wc -l)
    storageprofile=$(kubectl get storageprofile | wc -l)
    if [ "$storageclass" = "$storageprofile" ]; then
        echo "All the storageprofiles has been created."
        sleep 30
        exit 0
    else
        echo "Waiting for all the storageprofiles to be deployed. Retrying in 30 seconds..."
        sleep $retry_wait_time
        ((attempt++))
    fi
done

echo "Maximum retry attempts reached."
exit 1
