#!/bin/bash
echo "WARNING!!!!"
echo "This implementation is supported on the following platforms:"
echo "Openshift Container Platform v3.11+"
read -p "Are you sure? Type Y or y to continue" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# Deploy OCP Prerequisites
oc apply -f deploy/openshift/prereqs-ocp-aci-operator.yaml

# Deploy CRD
oc apply -f deploy/crds/rmlab_v1alpha1_acinamespace_crd.yaml

# Deploy OCP Operator
oc apply -f deploy/openshift/deploy-ocp-aci-operator.yaml