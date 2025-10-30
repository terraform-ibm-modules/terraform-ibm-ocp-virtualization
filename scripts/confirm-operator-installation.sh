#!/bin/bash

echo "Waiting for install plan to be created"
sleep 120

for i in {1..30}; do
  if kubectl get installplan -n openshift-cnv | grep kubevirt-hyperconverged | grep -q true; then
    echo "Install plan is ready and approved ✅"
    break
  fi
  echo "waiting for installplan to be ready"
  sleep 10
done


for i in {1..10}; do
  if kubectl wait csv -n openshift-cnv \
    -l operators.coreos.com/kubevirt-hyperconverged.openshift-cnv \
    --for=jsonpath='{.status.phase}=Succeeded' --timeout=300s >/dev/null 2>&1; then
    echo "✅ CSV succeeded"
    break
  fi
  echo "waiting... ($i)"
  sleep 10
done

echo "Waiting for hco-webhook deployment to be available..."
kubectl wait --for=condition=available deployment/hco-webhook -n openshift-cnv --timeout=15m
echo "✅ hco-webhook deployment is available."

echo "Verifying all pods are in Running state..."
kubectl wait --for=condition=Ready pods -l name=hyperconverged-cluster-webhook -n openshift-cnv --timeout=5m && sleep 10
echo "✅ All hco-webhook pods are running."

echo "Waiting for HyperConverged CRD to be available..."
kubectl wait --for=condition=NamesAccepted crd/hyperconvergeds.hco.kubevirt.io --timeout=300s
echo "✅ CRD is installed.Proceeding to custom resource installation"
