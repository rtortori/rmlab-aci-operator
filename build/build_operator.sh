#!/bin/bash

# Builds the operator
operator-sdk build rtortori/rmlab-aci-operator:apic4.1-v1alpha1

# Push to Docker Hub
docker push rtortori/rmlab-aci-operator:apic4.1-v1alpha1