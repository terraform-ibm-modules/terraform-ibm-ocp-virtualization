#!/bin/bash

set -e

# The binaries downloaded by the install-binaries script are located in the /tmp directory.
export PATH=$PATH:${1:-"/tmp"}

NAMESPACE="openshift-cnv"
COUNTER=0
MAX_ATTEMPTS=60 # 60 attempts * 10 seconds = 10 minutes max wait
SLEEP_INTERVAL=10

echo "========================================="
echo "Checking HyperConverged CRD installation status..."
echo "========================================="

# Function to check if CRD exists
check_crd_exists() {
    kubectl get crd hyperconvergeds.hco.kubevirt.io &>/dev/null
}

# Function to check if CSV (ClusterServiceVersion) is succeeded
check_csv_status() {
    local csv_status
    csv_status=$(kubectl get csv -n "$NAMESPACE" -l operators.coreos.com/kubevirt-hyperconverged."$NAMESPACE" -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NotFound")

    if [[ "$csv_status" == "Succeeded" ]]; then
        return 0
    else
        echo "CSV status: $csv_status"
        return 1
    fi
}

# Wait for CRD to be created
echo "Step 1: Waiting for HyperConverged CRD to be created..."
while [[ $COUNTER -lt $MAX_ATTEMPTS ]]; do
    if check_crd_exists; then
        echo "✓ HyperConverged CRD is now available."
        break
    fi

    COUNTER=$((COUNTER + 1))
    echo "Attempt $COUNTER/$MAX_ATTEMPTS: HyperConverged CRD not found, retrying in ${SLEEP_INTERVAL}s..."
    sleep $SLEEP_INTERVAL
done

if [[ $COUNTER -eq $MAX_ATTEMPTS ]]; then
    echo "ERROR: HyperConverged CRD did not become available within $((MAX_ATTEMPTS * SLEEP_INTERVAL)) seconds."
    echo "Available CRDs:"
    kubectl get crd | grep -i hyperconverged || echo "No HyperConverged CRDs found"
    exit 1
fi

# Reset counter for CSV check
COUNTER=0

# Wait for CSV to be in Succeeded state
echo ""
echo "Step 2: Waiting for ClusterServiceVersion to reach 'Succeeded' state..."
while [[ $COUNTER -lt $MAX_ATTEMPTS ]]; do
    if check_csv_status; then
        echo "✓ ClusterServiceVersion is in 'Succeeded' state."
        break
    fi

    COUNTER=$((COUNTER + 1))
    echo "Attempt $COUNTER/$MAX_ATTEMPTS: CSV not ready, retrying in ${SLEEP_INTERVAL}s..."
    sleep $SLEEP_INTERVAL
done

if [[ $COUNTER -eq $MAX_ATTEMPTS ]]; then
    echo "ERROR: ClusterServiceVersion did not reach 'Succeeded' state within $((MAX_ATTEMPTS * SLEEP_INTERVAL)) seconds."
    echo "Current CSV status:"
    kubectl get csv -n "$NAMESPACE" -l operators.coreos.com/kubevirt-hyperconverged."$NAMESPACE" || echo "No CSV found"
    exit 1
fi

# Reset counter for operator pods check
COUNTER=0

# Wait for operator pods to be ready
echo ""
echo "Step 3: Waiting for HyperConverged operator pods to be ready..."
while [[ $COUNTER -lt $MAX_ATTEMPTS ]]; do
    # Check if all pods with kubevirt-hyperconverged label are running and ready
    TOTAL_PODS=$(kubectl get pods -n "$NAMESPACE" -l name=hyperconverged-cluster-operator --no-headers 2>/dev/null | wc -l | tr -d ' ')

    if [[ $TOTAL_PODS -gt 0 ]]; then
        # Count pods that are NOT ready
        NOT_READY=$(kubectl get pods -n "$NAMESPACE" -l name=hyperconverged-cluster-operator -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null | grep -o "False" | wc -l | tr -d ' ')

        if [[ $NOT_READY -eq 0 ]]; then
            echo "✓ All HyperConverged operator pods are ready ($TOTAL_PODS pods)."
            break
        else
            COUNTER=$((COUNTER + 1))
            echo "Attempt $COUNTER/$MAX_ATTEMPTS: Operator pods not all ready (Total: $TOTAL_PODS, Not Ready: $NOT_READY), retrying in ${SLEEP_INTERVAL}s..."
        fi
    else
        COUNTER=$((COUNTER + 1))
        echo "Attempt $COUNTER/$MAX_ATTEMPTS: No operator pods found yet, retrying in ${SLEEP_INTERVAL}s..."
    fi

    sleep $SLEEP_INTERVAL
done

if [[ $COUNTER -eq $MAX_ATTEMPTS ]]; then
    echo "ERROR: HyperConverged operator pods did not become ready within $((MAX_ATTEMPTS * SLEEP_INTERVAL)) seconds."
    echo "Current pod status:"
    kubectl get pods -n "$NAMESPACE" -l name=hyperconverged-cluster-operator || echo "No operator pods found"
    exit 1
fi

echo ""
echo "========================================="
echo "✓ HyperConverged CRD is successfully installed and operator is running!"
echo "========================================="

# Made with Bob
