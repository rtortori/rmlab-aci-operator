#!/bin/bash

# Deploy OCP Prerequisites
oc apply -f deploy/openshift/prereqs-ocp-aci-operator.yaml

# Deploy OCP Operator
oc apply -f deploy/openshift/deploy-ocp-aci-operator.yaml

# Deploy CRD
oc apply -f deploy/crds/rmlab_v1alpha1_acinamespace_crd.yaml