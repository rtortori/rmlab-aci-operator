#!/bin/bash
echo "This implementation is supported on the following platforms:"
echo "Kubernetes v1.11.3+"

# Deploy Kubernetes Prerequisites
kubectl apply -f deploy/kubernetes/prereqs-k8s-aci-operator.yaml

# Deploy CRD
kubectl apply -f deploy/crds/rmlab.cisco.com_acinamespaces_crd.yaml

# Deploy Kubernetes Operator
kubectl apply -f deploy/kubernetes/deploy-k8s-aci-operator.yaml