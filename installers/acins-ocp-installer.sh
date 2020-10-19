ocp apply -f ../manifests/acinamespaces-rbac-openshift.yaml
ocp apply -f ../manifests/acinamespaces-crd.yaml
ocp apply -f ../manifests/acinamespaces-controller-openshift.yaml
