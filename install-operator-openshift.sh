#!/bin/bash

echo "This implementation is supported on the following platforms:"
echo "Openshift Container Platform v3.11+"

# Deploy OCP Prerequisites
oc apply -f deploy/openshift/prereqs-ocp-aci-operator.yaml

# Deploy CRD
oc apply -f deploy/crds/rmlab.cisco.com_acinamespaces_crd.yaml

# Deploy OCP Operator
oc apply -f deploy/openshift/deploy-ocp-aci-operator.yaml