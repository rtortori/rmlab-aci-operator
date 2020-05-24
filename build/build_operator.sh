#!/bin/bash

# Builds the operator
operator-sdk build rtortori/rmlab-aci-operator:apic4.2-v1alpha2

# Push to Docker Hub
docker push rtortori/rmlab-aci-operator:apic4.2-v1alpha2