#!/bin/bash

# Deploy Kubernetes Prerequisites
kubectl apply -f deploy/kubernetes/prereqs-k8s-aci-operator.yaml

# Deploy CRD
kubectl apply -f deploy/crds/rmlab_v1alpha1_acinamespace_crd.yaml

# Deploy Kubernetes Operator
kubectl apply -f deploy/kubernetes/deploy-k8s-aci-operator.yaml