#!/bin/bash

# Delete CRD
oc apply -f deploy/crds/rmlab_v1alpha1_acinamespace_crd.yaml

# Delete Kubernetes Operator
oc apply -f deploy/openshift/deploy-ocp-aci-operator.yaml

# Delete Kubernetes Prerequisites
oc apply -f deploy/openshift/prereqs-ocp-aci-operator.yaml