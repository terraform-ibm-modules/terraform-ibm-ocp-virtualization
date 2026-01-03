#!/bin/bash
set -e

echo "Waiting for install plan to be created"
sleep 120


for i in {1..30}; do
  if kubectl get installplan -n openshift-cnv | grep kubevirt-hyperconverged | grep -q true; then
    echo "✅ Install plan is ready and approved"
    break
  fi
  echo "waiting for installplan to be ready"
  sleep 10
done

for i in {1..10}; do
  echo "Attempt $i: waiting for hco-operator deployment to become Available..."
  if kubectl wait --for=condition=available deployment/hco-operator -n openshift-cnv --timeout=5m >/dev/null 2>&1; then
    echo "✅ hco-operator deployment is Available"
    break
  fi
  echo "Still not available, retrying... ($i)"
  sleep 10
done

for i in {1..10}; do
  echo "Attempt $i: waiting for hco-webhook deployment to become Available..."
  if kubectl wait --for=condition=available deployment/hco-webhook -n openshift-cnv --timeout=5m >/dev/null 2>&1; then
    echo "✅ hco-webhook deployment is Available"
    break
  fi
  echo "Still not available, retrying... ($i)"
  sleep 10
done


for i in {1..10}; do
  echo "Attempt $i: waiting for HyperConverged CRD to be available..."
  if kubectl get crd hyperconvergeds.hco.kubevirt.io >/dev/null 2>&1; then
    echo "✅ HyperConverged CRD is available"
    break
  fi
  echo "CRD not ready yet, retrying... ($i)"
  sleep 10
done

echo "✅ Proceeding to Custom Resource creation"
