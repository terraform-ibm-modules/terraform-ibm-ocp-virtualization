#!/bin/bash

echo "Waiting for install plan to be created"
sleep 120

kubectl run alpine --image=alpine --command sleep 3333

for i in {1..30}; do
  if kubectl get installplan -n openshift-cnv | grep kubevirt-hyperconverged | grep -q true; then
    echo "Install plan is ready and approved ✅"
    break
  fi
  echo "waiting for installplan to be ready"
  sleep 10
done



for i in {1..10}; do
  echo "Attempt $i: waiting for hco-operator deployment to become Available..."
  if kubectl wait --for=condition=available deployment/hco-operator -n openshift-cnv --timeout=90s >/dev/null 2>&1; then
    echo "✅ hco-operator deployment is Available"
    break
  fi
  echo "⏳ Still not available, retrying... ($i)"
  sleep 10
done



echo "Waiting for hco-webhook deployment to be available..."
kubectl wait --for=condition=available deployment/hco-webhook -n openshift-cnv --timeout=15m

echo "Verifying all pods are in Running state..."
kubectl wait --for=condition=Ready pods -l name=hyperconverged-cluster-webhook -n openshift-cnv --timeout=5m && sleep 10

echo "Waiting for HyperConverged CRD to be available..."
kubectl wait --for=condition=NamesAccepted crd/hyperconvergeds.hco.kubevirt.io --timeout=300s
echo "Proceeding to Custom Resource creation"
