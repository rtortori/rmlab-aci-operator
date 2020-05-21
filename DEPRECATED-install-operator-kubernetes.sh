#!/bin/bash
echo "WARNING!!!!"
echo "This implementation is supported on the following platforms:"
echo "Kubernetes v1.11.3+ and Kubernetes < 1.16"
read -p "Are you sure? Type Y or y to continue" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# Deploy Kubernetes Prerequisites
kubectl apply -f deploy/kubernetes/prereqs-k8s-aci-operator.yaml

# Deploy CRD
kubectl apply -f deploy/crds/DEPRECATED_rmlab_v1alpha1_acinamespace_crd.yaml

# Deploy Kubernetes Operator
kubectl apply -f deploy/kubernetes/deploy-k8s-aci-operator.yaml