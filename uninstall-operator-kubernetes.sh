#!/bin/bash

# Delete CRD
kubectl delete -f deploy/crds/rmlab.cisco.com_acinamespaces_crd.yaml

# Delete Kubernetes Operator
kubectl delete -f deploy/kubernetes/deploy-k8s-aci-operator.yaml

# Delete Kubernetes Prerequisites
kubectl delete -f deploy/kubernetes/prereqs-k8s-aci-operator.yaml