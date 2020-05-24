#!/bin/bash

# Delete CRD
oc delete -f deploy/crds/rmlab.cisco.com_acinamespaces_crd.yaml

# Delete Kubernetes Operator
oc delete -f deploy/openshift/deploy-ocp-aci-operator.yaml

# Delete Kubernetes Prerequisites
oc delete -f deploy/openshift/prereqs-ocp-aci-operator.yaml